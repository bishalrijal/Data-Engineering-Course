from datetime import datetime, timedelta, timezone
from qiskit_ibm_runtime import QiskitRuntimeService
try:
    from qiskit_ibm_runtime.api.exceptions import RequestsApiError
except ImportError:
    RequestsApiError = Exception

service = QiskitRuntimeService()
now = datetime.now(timezone.utc)

def snap(backend, days_back):
    try:
        props = backend.properties(datetime=now - timedelta(days=days_back))
    except RequestsApiError:          # 404 => backend didn't exist yet = past the edge
        return None
    return props.last_update_date.date() if props else None

def find_horizon(name):
    backend = service.backend(name)
    print(f"\n=== {name} ===")
    lo, hi, d = 0, None, 30
    while True:                        # exponential search for first failure
        date = snap(backend, d)
        print(f"-{d:>4}d -> {date or 'not found (edge)'}")
        if date is None:
            hi = d; break
        lo = d
        if d > 2048: break
        d *= 2
    if hi is None:
        print(f"history exceeds {lo} days"); return
    while hi - lo > 1:                 # binary search the exact edge
        mid = (lo + hi) // 2
        date = snap(backend, mid)
        print(f"-{mid:>4}d -> {date or 'not found (edge)'}")
        if date is None: hi = mid
        else: lo = mid
    print(f"oldest retrievable ≈ {lo} days back  ({snap(backend, lo)})")

for name in ["ibm_kingston", "ibm_fez", "ibm_marrakesh"]:
    find_horizon(name)