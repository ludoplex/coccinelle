def build_report(p, msg):
        return f"{p.file}:{p.line}:{p.column}-{p.column_end}: {msg}"

def print_report(p, msg="ERROR") :
        print(build_report(p, msg))
