import processing.serial.*;

import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import cc.arduino.*;
import org.firmata.*;

ControlDevice cont;
ControlIO control;

Arduino arduino;

// VARIABLES PARA MAPEAR INPUTS DEL CONTROL
float thumbRight;
float thumbLeft;
float trigger;
float bumperR;
float bumperL;
float rotOFF;
float START_SEQ;
float SEC_ON=0;
// VARIABLES QUE CONTROLAN MOVIMIENTOS DE SERVO, CON SUS RESPECTIVOS VALORES INICIALES
float estadoBase = 90;
float thumbRight0 = 47;
float thumbLeft0 = 79;
float trigger0 = 139.65118;

int FSR;

int fsrPin = 0;     // the FSR and 10K pulldown are connected to a0
int fsrReading;     // the analog reading from the FSR resistor divider
int fsrHoldingCan;
int offset = 0;


void setup() {
  size(500,500);
  control = ControlIO.getInstance(this);
  cont = control.getMatchedDevice("xbox_control");
  
  if(cont == null){
    println("El control no está conectado.");
    System.exit(-1);
  }
  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  arduino.pinMode(8, Arduino.SERVO);
  arduino.pinMode(7, Arduino.SERVO);
  arduino.pinMode(6, Arduino.SERVO);
  arduino.pinMode(5, Arduino.SERVO);
  arduino.pinMode(FSR, Arduino.INPUT);
}

public void getUserInput(){
  
  ////////////////////////////  MAPEO DE CADA INPUT DEL CONTROL  /////////////////////////////
  
  trigger = map(cont.getSlider("Shoulder").getValue(), -1, 1, 0, 180);
  thumbRight = map(cont.getSlider("Wrist").getValue(), -1, 1, 0, 180);
  thumbLeft = map(cont.getSlider("Elbow").getValue(), -1, 1, 0, 180);  
  bumperR = map(cont.getButton("BaseRight").getValue(), 0, 1, 0, 1);
  bumperL = map(cont.getButton("BaseLeft").getValue(), 0, 1, 0, 1);
  rotOFF = map(cont.getButton("RotateOFF").getValue(), 0, 1, 0, 1);
  //START_SEQ = map(cont.getButton("START_SEQ").getValue(), 0, 1, 0, 1);
  
  ////////////////////////////  SECUENCIA DE GOLPE DE LATA  /////////////////////////////
  
  fsrReading = arduino.analogRead(FSR);
  fsrHoldingCan = fsrReading - offset;
  ////////////////////////////  MOVIMIENTO DE SERVO BASE  /////////////////////////////

  if(bumperR==8){
    estadoBase=0;
  }
  if(bumperL==8){
    estadoBase=180;
  }
  if(rotOFF==8){
    estadoBase=90;
  }
  
  ////////////////////////////  MOVIMIENTO DE SERVO SHOULDER  /////////////////////////////
  
  if(trigger == 0.35156786){
      trigger0 = trigger0 + 1;
      if(trigger0 > 179.65118){
        trigger0 = 179.65118;
      }
  }
  if(trigger == 179.65118){
      trigger0 = trigger0 - 1;
      if(trigger0 < 0.35156786){
        trigger0 = 0.35156786;
      }
  }
  
  ////////////////////////////  MOVIMIENTO DE SERVO ELBOW  /////////////////////////////
  
   if(thumbLeft == 0){
      thumbLeft0 = thumbLeft0 + 1;
      if(thumbLeft0 > 180){
        thumbLeft0 = 180;
      }
  }
  if(thumbLeft == 180){
      thumbLeft0 = thumbLeft0 - 1;
      if(thumbLeft0 < 0){
        thumbLeft0 = 0;
      }
  }
    
  ////////////////////////////  MOVIMIENTO DE SERVO WRIST  /////////////////////////////
  
  if(thumbRight == 0){
      thumbRight0 = thumbRight0 + 1;
      if(thumbRight0 > 180){
        thumbRight0 = 180;
      }
  }
  if(thumbRight == 180){
      thumbRight0 = thumbRight0 - 1;
      if(thumbRight0 < 0){
        thumbRight0 = 0;
      }
  }
    
  ////////////////////////////  IMPRIMIR ESTADO DE TODOS LOS SERVOS  /////////////////////////////
  
  if(estadoBase==80){
    println("Base rotation: clockwise");
  }
  else if(estadoBase==100){
    println("Base rotation: counter-clockwise");
  }
  else if(estadoBase==90){
    println("Base rotation: static");
  }
  println("Shoulder: ", trigger0);
  println("Elbow: ", thumbLeft0);
  println("Wrist: ", thumbRight0);
  println("Lectura de FSR = ", fsrHoldingCan);
  println("    ");
  //delay(500);
}

void draw(){
  getUserInput();
  arduino.servoWrite(8, (int)estadoBase);   //BASE
  arduino.servoWrite(7, (int)thumbRight0);  //MUÑECA
  arduino.servoWrite(6, (int)thumbLeft0);   //CODO
  arduino.servoWrite(5, (int)trigger0);     //HOMBRO
  
}
