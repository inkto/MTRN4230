MODULE MTRN4230_Move_Sample
    
    ! Tom add this ================================================================================
    ! This variable is used to trigger interrupt 
    ! when the data of blocks on table ready
    ! VAR intnum tableDataInt;
    ! Tom add this==========================
    VAR bool isTableReady;
    VAR num conveyorTargetArray{128};
    VAR num tableTargetArray{128};
    
    VAR num points{4,60};
    
    ! Variables below will be shared between two tasks
    PERS string tableBlocksData;
    PERS string conveyorBlocksData;
    PERS string targetBlocksData;
    
    PERS bool isTableBlocksAvaliable;
    PERS bool isConveyorBlocksAvaliable;
    PERS bool isTableBlocksCleared;
    PERS bool isConveyorBlocksCleared;
    PERS bool turnConveyorOn;
    PERS bool turnVacumOn;
    PERS bool turnVacSolOn;
    PERS bool targetBlocksDataReady;
    ! ======================================
    
   
    ! Increase the x coordinate with 100mm
    ! Target_1 is the block position
    ! Might test it for sigularity position
    VAR robtarget Target_1 :=  [[-100,409,22],[0,-0.7071068,0.7071068,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    ! lift up the block for 130 mm (13cm)
    VAR robtarget WayPoint_1 :=  [[-100,409,152],[0,-0.7071068,0.7071068,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    ! move to the place which is 150 mm above the conveyor home position
    VAR robtarget WayPoint_2 := [[0,409,172],[0,-0.7071068,0.7071068,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    ! =============================================================================================
    
    ! The Main procedure. When you select 'PP to Main' on the FlexPendant, it will go to this procedure.
    ! Tom change it from MainMove to main
    PROC main()
!        CONNECT tableDataInt WITH table_isr;
!        ISignalDO DO10_5, 1, tableDataInt;
        
        ! The process call in this part will not be adapted =====================================
        ! This part is given in sample code =====================================================
        
        ! This is a procedure defined in a System Module, so you will have access to it.
        ! This will move the robot to its calibration.
        ! MoveToCalibPos;
        
        ! Call a procedure that we have defined below.
        ! MoveJSample;
        
        ! Call another procedure that we have defined.
        ! MoveLSample;
        
        ! Call another procedure, but provide some input arguments.
        ! VariableSample pTableHome, 100, 100, 0, v100, fine;
        
        ! =========================================================================================
        ! =========================================================================================
        SetDO CakePrinted, 0;        
        WaitDI CakeReady, 1;
        
        targetBlocksDataReady := TRUE;
        
        ! Tom add this ===================================================
        ! Test if the interrupt has been done
        IF targetBlocksDataReady = TRUE THEN
            TPWrite "Task move receive blocks data";
             MoveToCalibPos;
            SingArea \Wrist;
            MoveL Target_1, v100, fine,tSCup;
            
            TurnVacOn;
            SetDo DO10_2, 1;
            
            ! Wait for 3 sec to ensure the block is sucked 
            WaitTime 3;
            ! After picking up the block, lift it up
            ! i.e : increase the z-coordinate
            ! z = z + 150
            LiftTheObjectInZ Target_1, 0, 0, 150, v100, fine;
            
            ! Move to the waypoint
            ! waypoint is 150mm above the conveyor
            MoveToWaypoint;
            TPWrite "Above conveyor";
            
            ! Move to the final point
            ! Suppose it is 10mm above the table
            MoveJSample;
            SetDo DO10_2, 0;
            TurnVacOff;
            
            SingArea \Off;
            ! ==============================================================
        
        ENDIF
        
        SetDO CakePrinted, 1;
        
        WaitDI CakePicked, 1;
        
        SetDO CakePrinted, 0;
        
    ENDPROC
    
    PROC MoveJSample()
    
        ! 'MoveJ' executes a joint motion towards a robtarget. This is used to move the robot quickly from one point to another when that 
        !   movement does not need to be in a straight line.
        ! 'pTableHome' is a robtarget defined in system module. The exact location of this on the table has been provided to you.
        ! 'v100' is a speeddata variable, and defines how fast the robot should move. The numbers is the speed in mm/sec, in this case 100mm/sec.
        ! 'fine' is a zonedata variable, and defines how close the robot should move to a point before executing its next command. 
        !   'fine' means very close, other values such as 'z10' or 'z50', will move within 10mm and 50mm respectively before executing the next command.
        ! 'tSCup' is a tooldata variable. This has been defined in a system module, and represents the tip of the suction cup, telling the robot that we
        !   want to move this point to the specified robtarget. Please be careful about what tool you use, as using the incorrect tool will result in
        !   the robot not moving where you would expect it to. Generally you should be using
        MoveJ pTableHome, v100, fine, tSCup;
        
    ENDPROC
    
    PROC MoveLSample()
        
        ! 'MoveL' will move in a straight line between 2 points. This should be used as you approach to pick up a chocolate
        ! 'Offs' is a function that is used to offset an existing robtarget by a specified x, y, and z. Here it will be offset 100mm in the positive z direction.
        !   Note that function are called using brackets, whilst procedures and called without brackets.
        MoveL Offs(pTableHome, 0, 0, 100), v100, fine, tSCup;
        
    ENDPROC
    
    PROC VariableSample(robtarget target, num x_offset, num y_offset, num z_offset, speeddata speed, zonedata zone)
        
        ! Call 'MoveL' with the input arguments provided.
        MoveL Offs(target, x_offset, y_offset, z_offset), speed, zone, tSCup;
        
    ENDPROC
    
    ! Tom add this ==========================================================================
    ! define the interrupt service routine
    ! when the positon, types , and number of blocks on the table ready 
!    TRAP table_isr
!        TPWrite "Enter table_isr";
!        TPWrite "Table data ready";
!    ENDTRAP
    
    ! This function lift the object (block) in z-direction
    PROC LiftTheObjectInZ(robtarget target, num x_offset, num y_offset, num z_offset, speeddata speed, zonedata zone)
        ! Call 'MoveL' with the input arguments provided.
        MoveL Offs(target, x_offset, y_offset, z_offset), speed, zone, tSCup;
    ENDPROC
    
    ! This function is defined to move robot to the specified waypoint
    PROC MoveToWaypoint()
        MoveL WayPoint_2, v100, fine, tSCup;
    ENDPROC
    
    PROC PickAndPlace(num cx, num cy, num tx, num ty, robtarget Target_conv, robtarget Target_table)
        ! move from calibration position to target 1
            ! start the vaccume 
            MoveToCalibPos;
            SingArea \Wrist;
            Target_conv.trans.x := cx;
            Target_conv.trans.y := cy;
            MoveL Target_conv, v100, fine,tSCup;
            
            TurnVacOn;
            SetDo DO10_2, 1;
            
            ! Wait for 3 sec to ensure the block is sucked 
            WaitTime 3;
            ! After picking up the block, lift it up
            ! i.e : increase the z-coordinate
            ! z = z + 150
            LiftTheObjectInZ Target_1, 0, 0, 150, v100, fine;
            
            ! Move to the waypoint
            ! waypoint is 150mm above the conveyor
            MoveToWaypoint;
            TPWrite "Above conveyor";
            
            ! Move to the final point
            ! Suppose it is 10mm above the table
            MoveJSample;
            SetDo DO10_2, 0;
            TurnVacOff;
            
            SingArea \Off;
    ENDPROC
    ! ======================================================================================= 
    
ENDMODULE