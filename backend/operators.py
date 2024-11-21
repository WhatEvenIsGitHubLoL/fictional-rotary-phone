import math
from typing import Dict, Callable

OPERATORS: Dict[str, Dict] = {
    '+': {'precedence': 1, 'associativity': 'left'},
    '-': {'precedence': 1, 'associativity': 'left'},
    '*': {'precedence': 2, 'associativity': 'left'},
    '/': {'precedence': 2, 'associativity': 'left'},
    '^': {'precedence': 3, 'associativity': 'right'},
}

FUNCTIONS: Dict[str, Dict] = {
    'sqrt': {
        'args': 1,
        'func': lambda x: math.sqrt(float(x))
    },
    'frac': {
        'args': 2,
        'func': lambda x, y: float(x) / float(y)
    },
    'root': {
        'args': 2,
        'func': lambda x, n: float(x) ** (1/float(n))
    },
}
