from typing import List

class Token:
    def __init__(self, type: str, value: str, args: List[str] = None):
        self.type = type
        self.value = value
        self.args = args or []

    def __str__(self):
        return f"Token({self.type}, {self.value}, {self.args})"
