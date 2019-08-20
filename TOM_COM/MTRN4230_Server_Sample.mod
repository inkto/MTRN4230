MODULE MTRN4230_Server_Sample    

    ! The socket connected to the client.
    VAR socketdev client_socket;
    ! The host and port that we will be listening for a connection on.
    PERS string host := "127.0.0.1";
    PERS string cc := "s02";
    CONST num port := 1025;
    
    ! Tom add this==========================
    VAR bool isTableReady := FALSE;
    
    ! Variables below will be shared between two tasks
    PERS string tableBlocksData := "";
    PERS string conveyorBlocksData := "";
    
    PERS bool isTableBlocksAvaliable := FALSE;
    PERS bool isConveyorBlocksAvaliable := FALSE;
    PERS bool isTableBlocksCleared := FALSE;
    PERS bool isConveyorBlocksCleared := FALSE;
    ! ======================================
    
    PROC Main ()
        IF RobOS() THEN
            TPWrite "A";
            host := "192.168.125.1";
        ELSE
            TPWrite "B";
            host := "127.0.0.1";
        ENDIF
        MainServer;
        
    ENDPROC

    PROC MainServer()
        
        VAR string received_str;
        VAR string table_str;
        VAR num received_str_length := 0;
        VAR num counter := 1;
        ListenForAndAcceptConnection;
            
        ! Receive a string from the client.
        SocketReceive client_socket \Str:=received_str;
            
        !==============================================================================
        ! Tom add this
        
        ! doing some processing of the string
        ! Update the value of  isTableReady when necessary
        !...........................................
        !...........................................
        
        TPWrite "String Received is: " + received_str;
        received_str_length := StrLen(received_str);
        
        WHILE counter <= received_str_length - 2 DO
            ! check letter in the string one by one
            table_str := StrPart(received_str, counter,1);
            
            IF table_str = "P" THEN
                TPWrite "isTableReady is set";
                isTableReady := TRUE;
            ENDIF
            
            TPWrite table_str;
            counter := counter + 1;
        ENDWHILE
        
        IF isTableReady = TRUE THEN
            ! Set the interrupt
            ! Use DO10_5 to set up Interrupt for table blocks 
            SetDO DO10_5, 1;
            TPWrite "Output is set";
            ! Send the message to Task T_ROB1
        ELSE
            ! Set the interrupt
            ! Use DO10_6 to set up Interrupt for conveyor blocks
            SetDO DO10_6, 1; 
        ENDIF
        
        !==============================================================================
        
        ! Send the string back to the client, adding a line feed character.
        SocketSend client_socket \Str:=(received_str + "\0A");

        CloseConnection;
		
    ENDPROC

    PROC ListenForAndAcceptConnection()
        
        ! Create the socket to listen for a connection on.
        VAR socketdev welcome_socket;
        SocketCreate welcome_socket;
        
        ! Bind the socket to the host and port.
        SocketBind welcome_socket, host, port;
        
        ! Listen on the welcome socket.
        SocketListen welcome_socket;
        
        ! Accept a connection on the host and port.
        SocketAccept welcome_socket, client_socket \Time:=WAIT_MAX;
        TPWrite "Connection established";
        
        ! ==================================================
        
        
        
        ! ==================================================
        
        ! Close the welcome socket, as it is no longer needed.
        SocketClose welcome_socket;
        
    ENDPROC
    

!    PROC ListenForAndAcceptConnection()
        
!        ! Create the socket to listen for a connection on.
!        VAR socketdev welcome_socket;
!        VAR string received_string;
!        VAR bool keep_listening := TRUE;
!        SocketCreate welcome_socket;
        
!        ! Bind the socket to the host and port.
!        SocketBind welcome_socket, host, port;
        
!        ! Listen on the welcome socket.
!        SocketListen welcome_socket;
        
!        ! Accept a connection on the host and port.
!        SocketAccept welcome_socket, client_socket \Time:=WAIT_MAX;
!        TPWrite "Connection established";
        
!        ! ==================================================
!        WHILE keep_listening DO
!            ! Waiting for a connection request
!            ! SocketAccept temp_socket, client_socket;
        
!             ! Accept a connection on the host and port.
!             SocketAccept welcome_socket, client_socket \Time:=WAIT_MAX;
!             TPWrite "Connection established";
            
!            ! Communication
!            SocketReceive client_socket \Str:=received_string;
!            TPWrite "Client wrote - " + received_string;
!            received_string := "";
!            SocketSend client_socket \Str:="Message acknowledged";
!            ! Shutdown the connection
!            SocketReceive client_socket \Str:=received_string;
!            TPWrite "Client wrote - " + received_string;
!            SocketSend client_socket \Str:="Shutdown acknowledged";
!            SocketClose client_socket;
!            ENDWHILE
!        ! ==================================================
        
!        ! Close the welcome socket, as it is no longer needed.
!        SocketClose welcome_socket;
        
!    ENDPROC


    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose client_socket;
    ENDPROC
    

ENDMODULE