from mip import Model, Var, BINARY, xsum

from autobridge.Floorplan.Utilities import *
from autobridge.Opt.DataflowGraph import Vertex, Edge

# refer to https://cs.stackexchange.com/questions/12102/express-boolean-logic-operations-in-zero-one-integer-linear-programming-ilp

def get_var_of_logic_and(m: Model, x1: Var, x2: Var) -> Var:
  """ return a binary variable represents the logic AND """
  _check_if_vars_binary(x1, x2)

  y = m.add_var(var_type=BINARY)
  m += y >= x1 + x2 - 1
  m += y <= x1
  m += y <= x2
  
  return y


def get_var_of_logic_or(m: Model, x1: Var, x2: Var) -> Var:
  """ return a binary variable represents the logic OR """
  _check_if_vars_binary(x1, x2)

  y = m.add_var(var_type=BINARY)
  m += y <= x1 + x2
  m += y >= x1
  m += y >= x2
  
  return y


def get_var_of_logic_xor(m: Model, x1: Var, x2: Var) -> Var:
  """ return a binary variable represents the logic XOR """
  _check_if_vars_binary(x1, x2)

  y = m.add_var(var_type=BINARY)
  m += y <= x1 + x2
  m += y >= x1 - x2
  m += y >= x2 - x1
  m += y <= 2 - x1 - x2

  return y


def get_var_of_logic_not(m: Model, x: Var) -> Var:
  """ return a binary variable represents the logic NOT """
  _check_if_vars_binary(x)

  y = m.add_var(var_type=BINARY)
  m += y >= 1 - x
  m += y <= 1 - x
  
  return y


def get_var_of_equal_zero(m: Model, x: Var) -> Var:
  """ return a binary variable represents if the input binary var equals zero """
  _check_if_vars_binary(x)
  return get_var_of_logic_not(m, x)

def get_var_of_equal_one(m: Model, x: Var) -> Var:
  _check_if_vars_binary(x)
  return x

def _check_if_vars_binary(*args) -> bool:
  """ check if the variables are BINARY """
  return all(v.var_type == BINARY for v in args)


def add_slr_0_1_crossing_constraint(
  m: Model,
  v_list: List[Vertex],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
  width_limit: int,
) -> None:
  """ restrict the SLR crossing between 0 and 1 """
  all_edges = get_all_edges(v_list)

  def is_edge_cross_slr_0_1(e: Edge) -> Var:
    src_in_slr0 = get_var_of_logic_and(
      m, 
      get_var_of_equal_zero(m, v2var_y1[e.src]),
      get_var_of_equal_zero(m, v2var_y2[e.src])
    )
    dst_in_slr0 = get_var_of_logic_and(
      m, 
      get_var_of_equal_zero(m, v2var_y1[e.dst]),
      get_var_of_equal_zero(m, v2var_y2[e.dst])
    )
    src_not_in_slr0 = get_var_of_logic_not(m, src_in_slr0)
    dst_not_in_slr0 = get_var_of_logic_not(m, dst_in_slr0)

    return get_var_of_logic_or(
      m,
      get_var_of_logic_and(m, src_in_slr0, dst_not_in_slr0),
      get_var_of_logic_and(m, dst_in_slr0, src_not_in_slr0)
    )

  m += xsum(e.width * is_edge_cross_slr_0_1(e) for e in all_edges) <= width_limit 


def add_slr_1_2_crossing_constraint(
  m: Model,
  v_list: List[Vertex],
  v2var_y1: Dict[Vertex, Var],
  width_limit: int,
) -> None:
  """ restrict the SLR crossing between 1 and 2 """
  all_edges = get_all_edges(v_list)

  def is_edge_cross_slr_1_2(e: Edge) -> Var:
    return get_var_of_logic_xor(m, v2var_y1[e.src], v2var_y1[e.dst])
  
  m += xsum(e.width * is_edge_cross_slr_1_2(e) for e in all_edges) <= width_limit 


def add_slr_2_3_crossing_constraint(
  m: Model,
  v_list: List[Vertex],
  v2var_y1: Dict[Vertex, Var],
  v2var_y2: Dict[Vertex, Var],
  width_limit: int,
) -> None:
  """ restrict the SLR crossing between 2 and 3 """
  all_edges = get_all_edges(v_list)

  def is_edge_cross_slr_2_3(e: Edge) -> Var:
    src_in_slr3 = get_var_of_logic_and(
      m, 
      get_var_of_equal_one(m, v2var_y1[e.src]),
      get_var_of_equal_one(m, v2var_y2[e.src])
    )
    dst_in_slr3 = get_var_of_logic_and(
      m, 
      get_var_of_equal_one(m, v2var_y1[e.dst]),
      get_var_of_equal_one(m, v2var_y2[e.dst])
    )
    src_not_in_slr3 = get_var_of_logic_not(m, src_in_slr3)
    dst_not_in_slr3 = get_var_of_logic_not(m, dst_in_slr3)

    return get_var_of_logic_or(
      m,
      get_var_of_logic_and(m, src_in_slr3, dst_not_in_slr3),
      get_var_of_logic_and(m, dst_in_slr3, src_not_in_slr3)
    )

  m += xsum(e.width * is_edge_cross_slr_2_3(e) for e in all_edges) <= width_limit
