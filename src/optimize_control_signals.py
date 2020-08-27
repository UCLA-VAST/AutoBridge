#! /usr/bin/python3.6

import re
import subprocess

# [FIXME] too messy, need to rewrite
def modify_start(file_name):
  with open(file_name, 'r') as f:
    lines = f.readlines()
  
  # safety check to avoid double processing
  for line in lines:
    if 'modify_rtl_start' in line:
      raise('ERROR: modify_rtl_start has already been applied!')

  new_lines = []
  new_pos = 0
  for pos in range(len(lines)):
    line = lines[pos]
    if '.ap_start(' in line:
      if '.ap_start(ap_start)' in line:
        new_lines.append(line)
        new_pos += 1
      else:
        m = re.search('.ap_start(.+?),', line)
        start_signal = m.group(1)[1:-1]
        # get the module name
        module_name = start_signal[:-12]
        # if 'read_engine' in module_name:

        insert_lines = []
        for i in range(4):
          insert_lines.append(f'(* dont_touch = "yes" *) reg {start_signal}_q{i};\n')
        insert_lines.append('initial begin\n')
        for i in range(4):
          insert_lines.append(f"#0 {start_signal}_q{i} = 1'b0;\n")
        insert_lines.append('end\n')
        insert_lines.append('always @ (posedge ap_clk) begin\n')
        insert_lines.append(f'  {start_signal}_q0 <= {start_signal};\n')
        for i in range(3):
          insert_lines.append(f'  {start_signal}_q{i+1} <= {start_signal}_q{i};\n')
        insert_lines.append(f'end\n\n')
        # insert lines
        dis = 0
        prev_pos = pos - 1
        while prev_pos >= 0:
          prev_line = lines[prev_pos]
          if prev_line.strip() == '':
            break
          dis += 1
          prev_pos -= 1
        for i in range(len(insert_lines)):
          new_lines.insert(new_pos - dis + i, insert_lines[i])

        # replace the current line
        cur_line = f'  .ap_start({start_signal}_q3),\n'
        new_lines.append(cur_line)

        new_pos += (1 + len(insert_lines))

        # else:
        #   new_lines.append("  .ap_start(1'b1),\n")
        #   new_pos += 1
    else:
      new_lines.append(line)
      new_pos += 1

  with open(file_name, 'w') as f:
    f.writelines('// Applied modify_rtl_start.py\n')
    f.writelines(new_lines)


def getResetTemplate():
  pro = []
  Q_LEVEL = 4
  for X in range(2):
    for Y in range(4):
      pro.append(f'(* keep = "true" *) reg ap_rst_n_inv_X{X}_Y{Y};\n')
      for q in range(1, Q_LEVEL):
        pro.append(f'(* keep = "true" *) reg ap_rst_n_inv_X{X}_Y{Y}_{q};\n')

  pro.append(f'always @ (posedge ap_clk) begin\n')
  for X in range(2):
    for Y in range(4):
      pro.append(f'  ap_rst_n_inv_X{X}_Y{Y} <= ap_rst_n_inv_X{X}_Y{Y}_1;\n')
      for q in range(1, Q_LEVEL-1):
        pro.append(f'  ap_rst_n_inv_X{X}_Y{Y}_{q} <= ap_rst_n_inv_X{X}_Y{Y}_{q+1};\n')
      pro.append(f'  ap_rst_n_inv_X{X}_Y{Y}_{Q_LEVEL-1} <= ~ap_rst_n;\n')
  pro.append(f'end\n')

  return pro

def getApDonePipeline(s):
  return f'''
  (* dont_touch = "yes" *) reg {s}_q1;
  (* dont_touch = "yes" *) reg {s}_q2;
  (* dont_touch = "yes" *) reg {s}_q3;
  (* dont_touch = "yes" *) reg {s}_q4;
  initial begin
  #0 {s}_q1 = 1'b0;
  #0 {s}_q2 = 1'b0;
  #0 {s}_q3 = 1'b0;
  #0 {s}_q4 = 1'b0;
  end
  always @ (posedge ap_clk) begin
    {s}_q1 <= {s};
    {s}_q2 <= {s}_q1;
    {s}_q3 <= {s}_q2;
    {s}_q4 <= {s}_q3;
  end\n'''

def getApSyncDonePipeline(wire_name):
  return f'''
  (* keep = "true" *) reg ap_sync_done_q1;
  (* keep = "true" *) reg ap_sync_done_q2;
  (* keep = "true" *) reg ap_sync_done_q3;
  (* keep = "true" *) reg ap_sync_done_q4;
  initial begin
  #0 ap_sync_done_q1 = 1'b0;
  #0 ap_sync_done_q2 = 1'b0;
  #0 ap_sync_done_q3 = 1'b0;
  #0 ap_sync_done_q4 = 1'b0;
  end
  always @ (posedge ap_clk) begin
    ap_sync_done_q1 <= {wire_name};
    ap_sync_done_q2 <= ap_sync_done_q1;
    ap_sync_done_q3 <= ap_sync_done_q2;
    ap_sync_done_q4 <= ap_sync_done_q3;
  end
  assign ap_sync_done = ap_sync_done_q4;\n'''

def getSignalsFromApSyncDone(line):
  line = line.replace('assign ap_sync_done = ', '')
  line = line.replace('(', '')
  line = line.replace(')', '')
  line = line.replace(';', '')
  line = line.replace('\n', '')
  signals = [s.replace(' ', '') for s in line.split('&')]
  return signals

def safetyCheck(file_name):
  with open (file_name, 'r') as f:
    line_str = f.read()
  # safety check to avoid double processing
  assert 'preprocess_hls_dataflow' not in line_str
  assert 'ap_sync_done' in line_str, 'ERROR: must use #pragma HLS dataflow disable_start_propagation'

def modify_continue_done(file_name):
  safetyCheck(file_name)

  with open (file_name, 'r') as f:
    lines = f.readlines()

  start_cnt = 0
  new_lines = []
  # new_pos = 0
  for pos in range(len(lines)):
    line = lines[pos]
    
    # filter comments
    line = line.split('//', 1)[0]    

    # make ap_idle the same as ap_done
    if 'assign ap_idle = ' in line:
      new_lines.append('assign ap_idle = ap_done;\n')

    # add pipelining to ap_done   
    elif 'assign ap_sync_done' in line:
      signals = getSignalsFromApSyncDone(line)

      # new ap_done with registers
      insert_lines = ''
      for s in signals:
        insert_lines += getApDonePipeline(s)
      insert_lines += 'assign ap_sync_done_wire = 1 ' + ''.join([f' & {s}_q4' for s in signals]) + ';\n'
      new_lines.append(insert_lines)
      new_lines += getApSyncDonePipeline('ap_sync_done_wire')
    
    # add template for regional reset signals
    # only add once
    elif re.search('wire[ ]*ap_start[ ]*;', line):
      new_lines.append(line)
      new_lines += getResetTemplate()

    else:
      new_lines.append(line)

  with open(file_name, 'w') as f:
    f.writelines('// Applied preprocess_hls_dataflow.py\n')
    f.writelines(new_lines)

def postProcessingAPSignals(file_name):
  modify_start(file_name)
  modify_continue_done(file_name)

if __name__ == '__main__':
  rtl_path = '/home/einsx7/pr/application/bucket_sort/original_check_64bit/bucket_sort/solution/syn/verilog/'
  top_name = 'bucket_sort_bucket_sort.v'

  postProcessingAPSignals(f'{rtl_path}/{top_name}')

  subprocess.run(['mv', f'{rtl_path}/{top_name}', f'{rtl_path}/{top_name}.backup'])
  subprocess.run(['mv', top_name, rtl_path])
