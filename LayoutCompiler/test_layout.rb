test_area_layout_a = Room.new()
test_area_layout_b = Room.new()
test_area_layout_c = Room.new()
test_area_layout_d = Room.new()
test_area_layout_e = Room.new()
test_area_layout_f = Room.new()
test_area_layout_g = Room.new()
test_area_layout_h = Room.new()
test_area_layout_i = Room.new()
test_area_layout_j = Room.new()
test_area_layout_k = Room.new()
test_area_layout_l = Room.new()

test_area_layout_a[:id] = test_area_layout_a
test_area_layout_a[:NExit] = "0"
test_area_layout_a[:EExit] = test_area_layout_b
test_area_layout_a[:SExit] = test_area_layout_e
test_area_layout_a[:WExit] = "0"
test_area_layout_a[:UExit] = "0"
test_area_layout_a[:DExit] = "0"


test_area_layout_b[:id] = test_area_layout_b
test_area_layout_b[:NExit] = "0"
test_area_layout_b[:EExit] = test_area_layout_c
test_area_layout_b[:SExit] = test_area_layout_f
test_area_layout_b[:WExit] = test_area_layout_a
test_area_layout_b[:UExit] = "0"
test_area_layout_b[:DExit] = "0"


test_area_layout_c[:id] = test_area_layout_c
test_area_layout_c[:NExit] = "0"
test_area_layout_c[:EExit] = test_area_layout_d
test_area_layout_c[:SExit] = test_area_layout_g
test_area_layout_c[:WExit] = test_area_layout_b
test_area_layout_c[:UExit] = "0"
test_area_layout_c[:DExit] = "0"


test_area_layout_d[:id] = test_area_layout_d
test_area_layout_d[:NExit] = "0"
test_area_layout_d[:EExit] = "0"
test_area_layout_d[:SExit] = test_area_layout_h
test_area_layout_d[:WExit] = test_area_layout_c
test_area_layout_d[:UExit] = "0"
test_area_layout_d[:DExit] = "0"


test_area_layout_e[:id] = test_area_layout_e
test_area_layout_e[:NExit] = test_area_layout_a
test_area_layout_e[:EExit] = test_area_layout_f
test_area_layout_e[:SExit] = test_area_layout_i
test_area_layout_e[:WExit] = "0"
test_area_layout_e[:UExit] = "0"
test_area_layout_e[:DExit] = "0"


test_area_layout_f[:id] = test_area_layout_f
test_area_layout_f[:NExit] = test_area_layout_b
test_area_layout_f[:EExit] = test_area_layout_g
test_area_layout_f[:SExit] = test_area_layout_j
test_area_layout_f[:WExit] = test_area_layout_e
test_area_layout_f[:UExit] = "0"
test_area_layout_f[:DExit] = "0"


test_area_layout_g[:id] = test_area_layout_g
test_area_layout_g[:NExit] = test_area_layout_c
test_area_layout_g[:EExit] = test_area_layout_h
test_area_layout_g[:SExit] = test_area_layout_k
test_area_layout_g[:WExit] = test_area_layout_f
test_area_layout_g[:UExit] = "0"
test_area_layout_g[:DExit] = "0"


test_area_layout_h[:id] = test_area_layout_h
test_area_layout_h[:NExit] = test_area_layout_d
test_area_layout_h[:EExit] = "0"
test_area_layout_h[:SExit] = test_area_layout_l
test_area_layout_h[:WExit] = test_area_layout_g
test_area_layout_h[:UExit] = "0"
test_area_layout_h[:DExit] = "0"


test_area_layout_i[:id] = test_area_layout_i
test_area_layout_i[:NExit] = test_area_layout_e
test_area_layout_i[:EExit] = test_area_layout_j
test_area_layout_i[:SExit] = "0"
test_area_layout_i[:WExit] = "0"
test_area_layout_i[:UExit] = "0"
test_area_layout_i[:DExit] = "0"


test_area_layout_j[:id] = test_area_layout_j
test_area_layout_j[:NExit] = test_area_layout_f
test_area_layout_j[:EExit] = test_area_layout_k
test_area_layout_j[:SExit] = "0"
test_area_layout_j[:WExit] = test_area_layout_i
test_area_layout_j[:UExit] = "0"
test_area_layout_j[:DExit] = "0"


test_area_layout_k[:id] = test_area_layout_k
test_area_layout_k[:NExit] = test_area_layout_g
test_area_layout_k[:EExit] = test_area_layout_l
test_area_layout_k[:SExit] = "0"
test_area_layout_k[:WExit] = test_area_layout_j
test_area_layout_k[:UExit] = "0"
test_area_layout_k[:DExit] = "0"


test_area_layout_l[:id] = test_area_layout_l
test_area_layout_l[:NExit] = test_area_layout_h
test_area_layout_l[:EExit] = "0"
test_area_layout_l[:SExit] = "0"
test_area_layout_l[:WExit] = test_area_layout_k
test_area_layout_l[:UExit] = "0"
test_area_layout_l[:DExit] = "0"

