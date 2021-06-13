lappend system "i_clk"
lappend system "i_rst_p"

set num_added [ gtkwave::addSignalsFromList $system ]
<% targets.map((t, ti) => { %>
gtkwave::/Edit/Insert_Comment "---- t${ti} ----"

lappend t${ti} "top_tb.DUT.${t.data}"
lappend t${ti} "top_tb.DUT.${t.valid}"
lappend t${ti} "top_tb.DUT.${t.ready}"

set num_added [ gtkwave::addSignalsFromList $t${ti} ]
<% }) %>
<% initiators.map((i, ii) => { %>
gtkwave::/Edit/Insert_Comment "---- i${ii} ----"

lappend i${ii} "top_tb.DUT.${i.data}"
lappend i${ii} "top_tb.DUT.${i.valid}"
lappend i${ii} "top_tb.DUT.${i.ready}"

set num_added [ gtkwave::addSignalsFromList $i${ii} ]
<% }) %>
gtkwave::setZoomFactor -4
