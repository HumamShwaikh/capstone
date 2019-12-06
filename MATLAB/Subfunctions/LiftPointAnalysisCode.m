function LiftPointAnalysisCode(F_total_weight)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %       Variables and Method Calls for Lift Point Analysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Lift Point Properties Steel 1.6541
    LP_tensile = 1180e6; %(Pa)
    proof_stress = 980e6; %(Pa)

    %Lift Point Geometry
    %After iteration testing safety factor doesn't deviate much
    % 2m in heigh was chosen as it is optimum
    height = -2; % (m) test height

    %Lift Point Coords
    A_x = -1.637;
    A_y = 0;
    A_z = height;

    B_x = 0.900;
    B_y = -0.565;
    B_z = height;

    C_x = 0.900;
    C_y = 0.565;
    C_z = height;

    X_x = 0;
    X_y = 0;
    X_z = 0;

    theta_AXY = get_theta(-height, -A_x);
    theta_HXY = get_theta(B_x, -height);

    [F_a, F_b, F_c] = get_force_via_lift(F_total_weight, height, A_x, A_y, A_z, B_x, B_y, B_z, C_x, C_y, C_z);
    [F_w_a, F_w_b, F_w_c] = get_vert_comp(theta_AXY, theta_HXY, F_a, F_b, F_c);

    %Lift Point 137
    a_137 = 6e-3;
    b_137 = 137e-3;

    LP_137 = get_LP_n_full(a_137, b_137, F_w_a, proof_stress);

    %Lift Point 100
    a_100 = 4e-3;
    b_100 = 100e-3;

    LP_100 = get_LP_n_full(a_100, b_100, F_w_a, proof_stress);

    status = is_LP_safe(LP_100, LP_137);

    if status == true
        LP_100
        LP_137
    else
        NULL
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              Functions for Lift Point Analysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function theta = get_theta(top, bot)
        theta = atan((top) / (bot));
    end

    %Only consider case in z direction
    function root_bot = get_root_bot(x, y, z)
        root_bot = sqrt(x^2 + y^2 + z^2);
    end

    function [F_a, F_b, F_c] = get_force_via_lift(F_total_weight, height, A_x, A_y, A_z, B_x, B_y, B_z, C_x, C_y, C_z)
        A_root_bot = get_root_bot(A_x, A_y, A_z);
        A_z_comp = height / A_root_bot;

        B_root_bot = get_root_bot(B_x, B_y, B_z);
        B_z_comp = height / B_root_bot;

        C_root_bot = get_root_bot(C_x, C_y, C_z);
        C_z_comp = height / C_root_bot;

        F_b_end = ((1.447) * (A_z_comp)) + ((B_z_comp)) + ((C_z_comp));
        F_b = (-F_total_weight) / (F_b_end);
        F_c = F_b;
        F_a = (F_b) * (1.447);
    end

    function [F_w_a, F_w_b, F_w_c] = get_vert_comp(theta_AXY, theta_HXY, F_a, F_b, F_c)
        F_w_a = (F_a * sin(theta_AXY)) / 2;
        F_w_b = (F_b * sin(theta_HXY)) / 2;
        F_w_c = F_w_b;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              Functions for Lift Point Stress Analysis
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function LP_area = get_LP_area(a, b)
        LP_area = (1.414 * a * b) / (2);
    end

    function LP_stress = get_LP_stress(F_w_x, area)
        LP_stress = (F_w_x) / (area);
    end

    function LP_von_mises = get_LP_von_mises(stress)
        LP_von_mises = sqrt(4 * (stress^2));
    end

    function LP_n = get_LP_n(yield, von_mises)
        LP_n = yield / von_mises;
    end

    function LP_n_full = get_LP_n_full(a, b, F_w_a, proof_stress)
        A_LP = get_LP_area(a, b);
        stress_LP = get_LP_stress(F_w_a, A_LP);
        von_mises_LP = get_LP_von_mises(stress_LP);
        LP_n_full = get_LP_n(proof_stress, von_mises_LP);
    end

    function LP_safe = is_LP_safe(LP_n1, LP_n2)
        n_given = 2;

        if (LP_n1 > n_given) && (LP_n2 > n_given)
            LP_safe = true;
        else
            LP_safe = false;
        end

    end

end
