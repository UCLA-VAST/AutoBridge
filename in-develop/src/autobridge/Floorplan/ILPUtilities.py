from mip import Model, Var, BINARY

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