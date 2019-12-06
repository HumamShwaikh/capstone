function [m_frame, f_weight_frame] = FrameMassCode(tube_ID)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                  Variables for Mass of Frame
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tube_OD = 0.1;

    member1_l = get_length(0, 0, 0, 0, 0, 0.27);
    m1 = get_mass(tube_OD, tube_ID, member1_l); % member 1

    member2_l = get_length(0, 0, 0, 0, 0, 0.27);
    m2 = get_mass(tube_OD, tube_ID, member2_l); % member 2

    member3_l = get_length(0, 0, 0.27, -0.747, 0.515, 1.12);
    m3 = get_mass(tube_OD, tube_ID, member3_l); % member 3

    member4_l = get_length(0, 0, 0.27, -0.747, -0.515, 1.12);
    m4 = get_mass(tube_OD, tube_ID, member4_l); % member 4

    member5_l = get_length(-0.747, 0.515, 1.12, -0.747, -0.515, 1.12);
    m5 = get_mass(tube_OD, tube_ID, member5_l); % member 5

    member6_l = get_length(-0.747, 0.515, 1.12, -1.26, 0.515, 1.12);
    m6 = get_mass(tube_OD, tube_ID, member6_l); % member 6

    member7_l = get_length(-0.747, -0.515, 1.12, -1.26, -0.515, 1.12);
    m7 = get_mass(tube_OD, tube_ID, member7_l); % member 7

    member8_l = get_length(-1.26, 0.515, 1.12, -1.81, 0.515, 1.12);
    m8 = get_mass(tube_OD, tube_ID, member8_l); % member 8

    member9_l = get_length(-1.26, -.515, 1.12, -1.81, -.515, 1.12);
    m9 = get_mass(tube_OD, tube_ID, member9_l); % member 9

    member10_l = get_length(-1.81, 0.515, 1.12, -1.81, -0.515, 1.12);
    m10 = get_mass(tube_OD, tube_ID, member10_l); % member 10

    member11_l = get_length(-1.81, 0.515, 1.12, -2.51, 0.515, 1.12);
    m11 = get_mass(tube_OD, tube_ID, member11_l); % member 11

    member12_l = get_length(-1.81, -0.515, 1.12, -2.51, -.515, 1.12);
    m12 = get_mass(tube_OD, tube_ID, member12_l); % member 12

    member13_l = get_length(-2.51, 0.515, 1.12, -2.81, 0.515, 1.12);
    m13 = get_mass(tube_OD, tube_ID, member13_l); % member 13

    member14_l = get_length(-2.51, -0.515, 1.12, -2.81, -0.515, 1.12);
    m14 = get_mass(tube_OD, tube_ID, member14_l); % member 14

    member15_l = get_length(-2.81, 0.515, 1.12, -2.81, -0.515, 1.12);
    m15 = get_mass(tube_OD, tube_ID, member15_l); % member 15

    member16_l = get_length(-2.81, 0.515, 1.12, -4.3, 0.515, 1.12);
    m16 = get_mass(tube_OD, tube_ID, member16_l); % member 16

    member17_l = get_length(-2.81, -0.515, 1.12, -4.3, -0.515, 1.12);
    m17 = get_mass(tube_OD, tube_ID, member17_l); % member 17

    member18_l = get_length(0, 0, 0, -1.26, 0.9, 0);
    m18 = get_mass(tube_OD, tube_ID, member18_l); % member 18

    member19_l = get_length(0, 0, 0, -1.26, -.9, 0);
    m19 = get_mass(tube_OD, tube_ID, member19_l); % member 19

    member20_l = get_length(-1.26, 0.9, 0, -1.26, 0.9, 0);
    m20 = get_mass(tube_OD, tube_ID, member20_l); % member 20

    member21_l = get_length(-1.26, 0.9, 0, -2.51, 0.9, 0);
    m21 = get_mass(tube_OD, tube_ID, member21_l); % member 21

    member22_l = get_length(-1.26, -0.9, 0, -2.51, -0.9, 0);
    m22 = get_mass(tube_OD, tube_ID, member22_l); % member 22

    member23_l = get_length(-2.51, 0.9, 0, -2.51, -0.9, 0);
    m23 = get_mass(tube_OD, tube_ID, member23_l); % member 23

    member24_l = get_length(-2.51, 0.9, 0, -3.01, 0.9, 0);
    m24 = get_mass(tube_OD, tube_ID, member24_l); % member 24

    member25_l = get_length(-2.51, -0.9, 0, -3.01, -0.9, 0);
    m25 = get_mass(tube_OD, tube_ID, member25_l); % member 25

    member26_l = get_length(0, 0, -0.27, -0.81, 0.515, -1.12);
    m26 = get_mass(tube_OD, tube_ID, member26_l); % member 26

    member27_l = get_length(0, 0, -0.27, -0.812, -0.515, -1.12);
    m27 = get_mass(tube_OD, tube_ID, member27_l); % member 27

    member28_l = get_length(-0.81, 0.515, -1.12, -0.812, -0.515, -1.12);
    m28 = get_mass(tube_OD, tube_ID, member28_l); % member 28

    member29_l = get_length(-0.81, 0.515, -1.12, -1.26, 0.515, -1.12);
    m29 = get_mass(tube_OD, tube_ID, member29_l); % member 29

    member30_l = get_length(-0.812, -0.515, -1.12, -1.26, -0.515, -1.12);
    m30 = get_mass(tube_OD, tube_ID, member30_l); % member 30

    member31_l = get_length(-1.26, 0.515, -1.12, -1.81, 0.515, -1.12);
    m31 = get_mass(tube_OD, tube_ID, member31_l); % member 31

    member32_l = get_length(-1.26, -0.515, -1.12, -1.81, -0.515, -1.12);
    m32 = get_mass(tube_OD, tube_ID, member32_l); % member 32

    member33_l = get_length(-1.81, 0.515, -1.12, -1.81, -0.515, -1.12);
    m33 = get_mass(tube_OD, tube_ID, member33_l); % member 33

    member34_l = get_length(-1.81, 0.515, -1.12, -2.51, 0.515, -1.12);
    m34 = get_mass(tube_OD, tube_ID, member34_l); % member 34

    member35_l = get_length(-1.81, -0.515, -1.12, -2.51, -0.515, -1.12);
    m35 = get_mass(tube_OD, tube_ID, member35_l); % member 35

    member36_l = get_length(-2.51, 0.515, -1.12, -2.81, 0.515, -1.12);
    m36 = get_mass(tube_OD, tube_ID, member36_l); % member 36

    member37_l = get_length(-2.51, -0.515, -1.12, -2.81, -0.515, -1.12);
    m37 = get_mass(tube_OD, tube_ID, member37_l); % member 37

    member38_l = get_length(-2.81, 0.515, -1.12, -2.81, -0.515, -1.12);
    m38 = get_mass(tube_OD, tube_ID, member38_l); % member 38

    member39_l = get_length(-2.81, 0.515, -1.12, -4.3, 0.515, -1.12);
    m39 = get_mass(tube_OD, tube_ID, member39_l); % member 39

    member40_l = get_length(-2.81, -0.515, -1.12, -4.3, -0.515, -1.12);
    m40 = get_mass(tube_OD, tube_ID, member40_l); % member 40

    member41_l = get_length(-1.26, 0.9, 0, -1.26, 0.515, -1.12);
    m41 = get_mass(tube_OD, tube_ID, member41_l); % member 41

    member42_l = get_length(-1.26, 0.9, 0, -1.26, 0.515, 1.12);
    m42 = get_mass(tube_OD, tube_ID, member42_l); % member 42

    member43_l = get_length(-2.51, 0.9, 0, -2.51, 0.515, -1.12);
    m43 = get_mass(tube_OD, tube_ID, member43_l); % member 43

    member44_l = get_length(-2.51, 0.9, 0, -2.51, 0.515, 1.12);
    m44 = get_mass(tube_OD, tube_ID, member44_l); % member 44

    member45_l = get_length(-1.26, -0.9, 0, -1.26, -0.515, 1.12);
    m45 = get_mass(tube_OD, tube_ID, member45_l); % member 45

    member46_l = get_length(-1.26, -0.9, 0, -1.26, -0.515, -1.12);
    m46 = get_mass(tube_OD, tube_ID, member46_l); % member 46

    member47_l = get_length(-2.51, -0.9, 0, -2.51, -0.515, 1.12);
    m47 = get_mass(tube_OD, tube_ID, member47_l); % member 47

    member48_l = get_length(-2.51, -0.9, 0, -2.51, -0.515, -1.12);
    m48 = get_mass(tube_OD, tube_ID, member48_l); % member 48

    m_frame = m1 + m2 + m3 + m4 + m5 + m6 + m7 + m8 + m9 + m10 + m11 + m12 + m13 + m14 + m14 + m15 + m16 + m17 + m18 + m19 + m20 + m21 + m22 + m23 + m24 + m25 + m26 + m27 + m28 + m29 + m30 + m31 + m32 + m33 + m34 + m35 + m36 + m37 + m38 + m39 + m40 + m41 + m42 + m43 + m44 + m45 + m46 + m47 + m48;

    f_weight_frame = m_frame * 9.81

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                  Determine Mass of Frame
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function member_mass = get_mass(OD, ID, L)
        rho = 782; %(kg/m^3) SS 2205

        ROD = OD / 2;
        RID = ID / 2;

        m_OD = rho * pi * (ROD^2) * L;
        m_ID = rho * pi * (RID^2) * L;

        member_mass = m_OD - m_ID;
    end

    function member_length = get_length(x1, y1, z1, x2, y2, z2)
        member_length = sqrt(((x2 - x1)^2) + ((y2 - y1)^2) + ((z2 - z1)^2));
    end

end
