from main import positive_failure_f, FinalStr
try:
    print(positive_failure_f(FinalStr("hello")))  # Should raise TypeError
except TypeError as e:
    print(f"TypeError: {e}")
