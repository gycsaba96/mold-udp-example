
from p4rrot.generator_tools import *
from p4rrot.checks import *

class AssignZero(Command):
    
    def __init__(self,vname,env=None):
        self.vname = vname
        self.env = env
    
        if self.env!=None:
            self.check()
            
    def check(self):
        var_exists(self.vname,self.env)
        is_writeable(self.vname,self.env)
    
    def get_generated_code(self):
        gc = GeneratedCode()
        vi  = self.env.get_varinfo(self.vname)
        gc.get_apply().writeln(f"{vi['handle']} = 0;")
        return gc
    
    def execute(self,test_env):
        vi = self.env.get_varinfo(self.vname)
        test_env[self.vname] = vi['type'].cast_value(self.value)