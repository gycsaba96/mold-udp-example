from p4rrot.generator_tools import *
from p4rrot.known_types import *  
from p4rrot.standard_fields import *
from p4rrot.core.commands import *  

import plugins


fp = FlowProcessor(
        istruct = [('a',uint32_t),('b',uint32_t),('c',uint32_t),('l',bool_t)],
    )

(
fp
.add(If('l'))
        .add(StrictAddition('a','b','c'))
        .add(plugins.AssignZero('b'))
    .Else()
        .add(StrictSubtraction('a','b','c'))
        .add(plugins.AssignZero('c'))
    .EndIf()
)  

fs = FlowSelector(
        'IPV4_UDP',
        [(UdpDstPort,5555)],
        fp
    )


solution = Solution()
solution.add_flow_processor(fp)
solution.add_flow_selector(fs)
solution.get_generated_code().dump('output_code')