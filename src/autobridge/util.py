import ctypes
import io
import logging
import mip
import os, sys
import tempfile
from datetime import datetime
from pkg_resources import get_distribution
from contextlib import contextmanager


libc = ctypes.CDLL(None)
c_stdout = ctypes.c_void_p.in_dll(libc, 'stdout')

@contextmanager
def stdout_redirector(stream):
    # The original fd stdout points to. Usually 1 on POSIX systems.
    original_stdout_fd = sys.stdout.fileno()

    def _redirect_stdout(to_fd):
        """Redirect stdout to the given file descriptor."""
        # Flush the C-level buffer stdout
        libc.fflush(c_stdout)
        # Flush and close sys.stdout - also closes the file descriptor (fd)
        sys.stdout.close()
        # Make original_stdout_fd point to the same file as to_fd
        os.dup2(to_fd, original_stdout_fd)
        # Create a new sys.stdout that points to the redirected fd
        sys.stdout = io.TextIOWrapper(os.fdopen(original_stdout_fd, 'wb'))

    # Save a copy of the original stdout fd in saved_stdout_fd
    saved_stdout_fd = os.dup(original_stdout_fd)
    try:
        # Create a temporary file and redirect stdout to it
        tfile = tempfile.TemporaryFile(mode='w+b')
        _redirect_stdout(tfile.fileno())
        # Yield to caller, then redirect stdout back to the saved fd
        yield
        _redirect_stdout(saved_stdout_fd)
        # Copy contents of temporary file to the given stream
        tfile.flush()
        tfile.seek(0, io.SEEK_SET)
        stream.write(tfile.read())
    finally:
        tfile.close()
        os.close(saved_stdout_fd)


def get_mip_model_silent():
  """Create a mip model but filter out the Gurobi prints"""
  try:
    f = io.BytesIO()
    with stdout_redirector(f):
      m = mip.Model()
      m.verbose = 0
    return m
  except:
    logger = get_cli_logger()
    logger.error('*** ERROR: Failed to start Gurobi. Check if GUROBI_HOME and GRB_LICENSE_FILE are correctly set')
    logger.error('GUROBI_HOME is currently set to %s', os.environ.get('GUROBI_HOME', ''))
    logger.error('GRB_LICENSE_FILE is currently set to %s', os.environ.get('GRB_LICENSE_FILE', ''))
    exit(1)

def get_work_dir(config):
  return config.get('work_dir', '.')


def get_log_name(config):
  return f'{get_work_dir(config)}/autobridge-{datetime.now().strftime("%b-%d-%Y-%H:%M")}.log'


def get_file_logger():
  return logging.getLogger('autobridge')


def get_cli_logger():
  return logging.getLogger('general')


def init_logging(config) -> None:
  logger = get_file_logger()
  logger.parent = None
  log_file = get_log_name(config)
  handler = logging.FileHandler(log_file)
  handler.setFormatter(logging.Formatter('[%(levelname)s:%(module)s:%(lineno)d] %(message)s'))
  logger.addHandler(handler)
  logger.setLevel(logging.INFO)


def set_general_logger(config):
  general_logger = get_cli_logger()
  general_logger.parent = None
  general_logger.addHandler(logging.StreamHandler())
  general_logger.setLevel(logging.INFO)

  general_logger.addHandler(logging.FileHandler(get_log_name(config)))
  return general_logger


def print_start(config):
  __version__ = get_distribution('autobridge').version

  general_logger = get_cli_logger()
  general_logger.info('')
  general_logger.info('*********************************************')
  general_logger.info('***         Starting AutoBridge           ***')
  general_logger.info('*********************************************')
  general_logger.info('')
  general_logger.info('Version: %s', __version__)
  general_logger.info('')
  general_logger.info('Running details logged to ' + get_log_name(config))
  general_logger.info('')
  general_logger.info('----------------------------------------------')
  general_logger.info('')


def print_end():
  general_logger = get_cli_logger()
  general_logger.info('*********************************************')
  general_logger.info('***          AutoBridge Finishes          ***')
  general_logger.info('*********************************************')
  general_logger.info('')
