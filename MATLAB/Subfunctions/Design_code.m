%This function is the main "design" function.
function Design_code()%time, speed, depth)
    %Check if the user tries to run this file directly
    time = 6;
    speed = 6;
    depth = 1000;
    %DESIGN CALCULATIONS done here. Feel free to use as many subfunctions as necessary.
    [thruster_Name, thruster_Force, mount_angle_xy, thruster_power, thruster_diameter] = ThrusterFunction(speed);
    [hullThickness, hatchThickness, hullVolume, hullMass, batteries] = HHGP(time, depth, thruster_power);
    [final_OD, final_ID, final_tube_thickness] = HydroStaticBucklingCode(depth);
    [m_frame, f_weight_frame] = FrameMassCode(final_ID/1000);
    [CoM, CoB, componentMass] = COM_COB_Function(hullThickness, final_ID/1000);
    [Oxygen_m3, CO2_Canisters, Airflow_m3PerMin] = lifeSupportFunction(time, hullThickness);
    LiftPointAnalysisCode(f_weight_frame + componentMass + hullMass);
    
    %Source: Fundamentals of Machine Component Design Robert C. Juvinall and Kurt M, Marshek, Wiley; 5th edition.
    %function testing

    %Declaring text files to be modified
    %Files
    log_file = '..\\..\\Log\\SUB2A_LOG.txt';
    equation_file = '..\\..\\SolidWorks\\equations.txt';

    %Write the log file (NOT USED BY SOLIDWORKS, BUT USEFUL TO DEBUG PROGRAM AND REPORT RESULTS IN A CLEAR FORMAT)
    %Please only create one log file for the complete project but try to keep the file easy to read by adding blank lines and sections...
    fid = fopen(log_file, 'w+t');
    fprintf(fid, '***Logs***\n');
    fprintf(fid, 'Thruster Name = '+ thruster_Name+ '\n');
    fprintf(fid, strcat('Thruster Force =', 32, num2str(thruster_Force), ' (kN).\n'));
    fprintf(fid, strcat('There will be', 32, num2str(batteries), ' batteries on board.\n'));
    fprintf(fid, strcat('We assume that the shaft is made of 1100-0 Aluminm alloy.\n'));
    %fprintf(fid, strcat('Optimized shaft diameter =', 32, num2str(new_diameter), ' (mm).\n'));
    fclose(fid);
    
    %unit conversions
    hullThickness = hullThickness*1000; % m to mm
    hatchThickness = hatchThickness*1000;
    final_OD =final_OD*1000;
    final_tube_thickness =final_tube_thickness*1000;

    %Write the equations file(s) (FILE(s) LINKED TO SOLIDWORKS).
    %You can make a different file for each section of your project (ie one for steering, another for brakes, etc...)
    %or one single large file that includes all the equations. Its up to you!
    fid2 = fopen(equation_file, 'w+t');
    % "hatchHoleDiameter"= 600mm constant
    fprintf(fid2, strcat('"hatchHoleDiameter"=', num2str(600), 'mm\n\n'));
    % "hullThickness"
    fprintf(fid2, strcat('"hullThickness"=', num2str(hullThickness), 'mm\n\n'));
    % "gasketHullInterconnectWidth"= 100mm constant
    fprintf(fid2, strcat('"gasketHullInterconnectWidth"=', num2str(100), 'mm\n\n'));
    % "collarThickness"= 20mm constant
    fprintf(fid2, strcat('"hatchHcollarThicknessoleDiameter"=', num2str(20), 'mm\n\n'));
    % "hatchTunnelLength"=200 constant
    fprintf(fid2, strcat('"hatchTunnelLength"=', num2str(200), 'mm\n\n'));
    % "oRingDiameter"=2 constant
    fprintf(fid2, strcat('"oRingDiameter"=', num2str(2), 'mm\n\n'));
    % "boltPatternRadiusInterconnect"=500 constant
    fprintf(fid2, strcat('"boltPatternRadiusInterconnect"=', num2str(500), 'mm\n\n'));
    % "interconnectBoltDiameter"=30 constant
    fprintf(fid2, strcat('"interconnectBoltDiameter"=', num2str(30), 'mm\n\n'));
    % "hatchShaftDiameter"=20 constant
    fprintf(fid2, strcat('"hatchShaftDiameter"=', num2str(20), 'mm\n\n'));
    % "hatchMinima"=hatchThickness
    fprintf(fid2, strcat('"hatchMinima"=', num2str(hatchThickness), 'mm\n\n'));
    % "hullDiameter"=2240 constant
    fprintf(fid2, strcat('"hullDiameter"=', num2str(2240), 'mm\n\n'));
    % "hatchMaxima"=180 constant
    fprintf(fid2, strcat('"hatchMaxima"=', num2str(180), 'mm\n\n'));
    % "bushingFlatHatch"=15 constant
    fprintf(fid2, strcat('"bushingFlatHatch"=', num2str(15), 'mm\n\n'));
    % "hingePivotDiameter"=20 constant
    fprintf(fid2, strcat('"hingePivotDiameter"=', num2str(20), 'mm\n\n'));
    % "handleWidth"=250 constant
    fprintf(fid2, strcat('"handleWidth"=', num2str(250), 'mm\n\n'));
    % "handleHeight"=160 constant
    fprintf(fid2, strcat('"handleHeight"=', num2str(160), 'mm\n\n'));
    % "handleThickness"=25 constant
    fprintf(fid2, strcat('"handleThickness"=', num2str(25), 'mm\n\n'));
    % "hatchTopToDogArmCenter"=33mm constant
    fprintf(fid2, strcat('"hatchTopToDogArmCenter"=', num2str(33), 'mm\n\n'));
    % "dogArmSize"=30 constant
    fprintf(fid2, strcat('"dogArmSize"=', num2str(30), 'mm\n\n'));
    % "hatchPivotHeight"=40 constant
    fprintf(fid2, strcat('"hatchPivotHeight"=', num2str(40), 'mm\n\n'));
    % "hatchPivotDistance"=70 constant
    fprintf(fid2, strcat('"hatchPivotDistance"=', num2str(70), 'mm\n\n'));
    % "HatchORingDiameter"=2.1 constant
    fprintf(fid2, strcat('"HatchORingDiameter"=', num2str(2.1), 'mm\n\n'));
    % "FrameLength"= 2600 constant
    fprintf(fid2, strcat('"FrameLength"=', num2str(2600), 'mm\n\n'));
    % "FrameMidLength"= 1800 constant
    fprintf(fid2, strcat('"FrameMidLength"=', num2str(1800), 'mm\n\n'));
    % "TubeOD"= final_OD
    fprintf(fid2, strcat('"TubeOD"=', num2str(final_OD), 'mm\n\n'));
    % "FrameBackFlat"= 500 constant
    fprintf(fid2, strcat('"FrameBackFlat"=', num2str(500), 'mm\n\n'));
    % "TubeWall"= final_tube_thickness
    fprintf(fid2, strcat('"TubeWall"=', num2str(final_tube_thickness), 'mm\n\n'));
    % "TopMemberAngle"=140 constant
    fprintf(fid2, strcat('"TopMemberAngle"=', num2str(140), 'deg\n\n'));
    % "hatchThickness"= hatchThickness
    fprintf(fid2, strcat('"hatchThickness"=', num2str(hatchThickness), 'mm\n\n'));
    % "hatchEdgeToTop"=76.7095 constant
    fprintf(fid2, strcat('"hatchEdgeToTop"=', num2str(76.7095), 'mm\n\n'));
    % "mountAngle" = mount_angle_xy
    fprintf(fid2, strcat('"mountAngle"=', num2str(mount_angle_xy), 'deg\n\n'));
    % "ThrusterDim"= thruster_diameter
    fprintf(fid2, strcat('"ThrusterDim"=', num2str(thruster_diameter), 'mm\n\n'));
    % "FrameHight"= 2500 const
    fprintf(fid2, strcat('"FrameHight"=', num2str(2500), 'mm\n\n'));
    fclose(fid2);
end
