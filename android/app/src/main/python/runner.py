import io
import sys
import traceback
from contextlib import redirect_stdout, redirect_stderr


def run_code(code: str) -> str:
    """يشغّل كود بايثون ويرجّع الناتج (stdout + stderr) كنص."""
    out = io.StringIO()
    err = io.StringIO()
    scope = {"__name__": "__main__"}
    try:
        with redirect_stdout(out), redirect_stderr(err):
            exec(compile(code, "<script>", "exec"), scope)
    except SystemExit:
        pass
    except BaseException:
        err.write(traceback.format_exc())
    return out.getvalue() + err.getvalue()
