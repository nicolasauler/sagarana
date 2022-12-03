import processing.serial.*;      // importa biblioteca de comunicacao serial
import java.awt.event.KeyEvent;  // importa biblioteca para leitura de dados da porta serial
import java.io.IOException;
import java.util.*;
import java.util.Arrays;
import java.util.List;
import java.text.SimpleDateFormat;  
import java.util.Date;
import java.lang.Math;

Serial myPort; // definicao do objeto serial

//  ======= CONFIGURACAO SERIAL ==================

    String   porta= "COM5";  // <== acertar valor ***
    int   baudrate= 115200;  // 115200 bauds
    char    parity= 'N';     // sem paridade
    int   databits= 8;       // 8 bits de dados
    float stopbits= 2.0;     // 2 stop bits

//  ==============================================

String angle=""; //valor do ângulo
String distance=""; // valor da distância
String data=""; //ângulo,distância#
float  pixsDistance;
int contadorMedidas = 0;
int    iAngle, iDistance, iAnteriorAngle = 0;
int    index1=0; //posicao para limitar o valor do angulo
int    index2=0; //posicao para limitar o valor de distancia
String text = "";
String defaultText = "SAGARANA                                                                                                      TURMA 1 - BANCADA A6";
String problemText = "";

ArrayList<Integer> medidasRecebidas = new ArrayList<Integer>();
ArrayList<Integer> angulosRecebidos;
int[] medidasPorAngulos = new int[101];
int[] medidasPorAngulosAuxiliar = new int[101];
float numObj = 0;
ArrayList<Integer> listaDistancias = new ArrayList<Integer>();
ArrayList<Integer> listaMedidas = new ArrayList<Integer>();
int indiceInicial=0, indiceCentral=0, indiceFinal=0, indicador=0;
int modoDebug = 1;

// keystroke
int whichKey = -1;  // variavel mantem tecla acionada
PImage img;

Table table;

void setup() {
    size (960, 600);
    text = defaultText;
    smooth();
    img = loadImage("alerta.png");
    if (modoDebug == 0){
      myPort = new Serial(this, porta, baudrate, parity, databits, stopbits);
      myPort.bufferUntil('#');
      angulosRecebidos = new ArrayList<Integer>();
    }
    else{
      angulosRecebidos = new ArrayList<Integer>(Arrays.asList(20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,39,41,42,43,44,45,46,47,48,49,51,52,53,54,55,56,57,58,59,61,62,63,64,65,66,67,68,69,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,91,92,93,94,95,96,97,98,99,101,102,103,104,105,106,107,108,109,111,112,113,114,115,116,117,118,119,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,141,142,143,144,145,146,147,148,149,151,152,153,154,155,156,157,158,159,160));
    }
    table = loadTable("lidar_log.csv", "header");
    
    for (int i=0; i<medidasPorAngulos.length; i++){
      medidasPorAngulos[i]=0;
    }

}

void draw() {
    pushMatrix();
    translate(0,40);
    fill(98,245,31);
    noStroke();
    fill(255,255,255);
    rect(0, -40, width, 480+40);
    drawRadar();
    drawObject();
    drawText();
    popMatrix();
}

void drawRadar() {
    if (int(numObj) >= 2){
      problemText = "CUIDADO !!!                                           EXISTEM " + int(numObj) + " OBJETOS NO NOSSO CAMPO DE VISÃO !!!";
      text = problemText;
      background(img);
      stroke(255,255,255);
    }
    else{
      stroke(0,0,0);
    }
    pushMatrix();
    translate(480,480);
    noFill();
    strokeWeight(1.5);
    arc(0,0,1000,1000,10*PI/9,17*TWO_PI/18);
    arc(0,0,900,900,10*PI/9,17*TWO_PI/18);  
    arc(0,0,800,800,10*PI/9,17*TWO_PI/18);
    arc(0,0,700,700,10*PI/9,17*TWO_PI/18);
    arc(0,0,600,600,10*PI/9,17*TWO_PI/18);
    arc(0,0,500,500,10*PI/9,17*TWO_PI/18);
    arc(0,0,400,400,10*PI/9,17*TWO_PI/18);
    arc(0,0,300,300,10*PI/9,17*TWO_PI/18);
    arc(0,0,200,200,10*PI/9,17*TWO_PI/18);
    arc(0,0,100,100,10*PI/9,17*TWO_PI/18);
    line(0,0,469.8463,-171.0101);
    line(0,0,-469.8463,-171.0101);
    popMatrix();
}

void drawObject() {
  
  InterfaceReal();
  
}


void InterfaceReal(){
    
    if (modoDebug == 1){
      testarValores();
    }
    
    pushMatrix();
    translate(480,480);
    strokeWeight(15); 
    stroke(80,80,80); // azul
    
    for (int i=0; i < medidasRecebidas.size(); i++) {
      
        if (medidasRecebidas.get(i) > 100){
            medidasRecebidas.set(i,100);
        }
        
        pixsDistance = medidasRecebidas.get(i)*5;
        
        iAngle = angulosRecebidos.get(i);
        if (i!= 0){
          iAnteriorAngle = angulosRecebidos.get(i-1);
        }
       
        strokeWeight(2);
        
        line(0,0,pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)));
        
        // Serve para preencher com medida os ângulos não varridos pela FPGA
        
        if(iAngle == 31 || iAngle == 41 || iAngle == 51 || iAngle == 61 || iAngle == 71 || iAngle == 81 || iAngle == 91 || iAngle == 101 || iAngle == 111 || iAngle == 121 || iAngle == 131 || iAngle == 141 || iAngle == 151){
          line(0,0,pixsDistance*cos(radians(iAngle-1)),-pixsDistance*sin(radians(iAngle-1)));
        }
        
        //Na última medição, faz a contagem e cálculo da quantidade de objetos   
        if (i == 127){
        
          for (int j=0; j <= i; j++){
            if(medidasRecebidas.get(j) != 100){
              medidasPorAngulos[medidasRecebidas.get(j)] = medidasPorAngulos[medidasRecebidas.get(j)]+1;
            }
          }
           for (int j=0; j <= 100; j++){
            if(j != 100){
              print(medidasPorAngulos[j]+",");
            }
            else{
              print(medidasPorAngulos[j]);
            }
            if (j==50){
              print("\n");
            }
          }
                 
          for(int m=0; m<100; m++){
            
            if (medidasPorAngulos[m] != 0 || medidasPorAngulos[m+1] != 0){
              if (medidasPorAngulos[m] != 0){
                indiceInicial = m;
              }
              else{
                indiceInicial = m+1;
              }
            }
            
            while(medidasPorAngulos[m] != 0 || medidasPorAngulos[m+1] != 0){

              contadorMedidas = contadorMedidas+medidasPorAngulos[m];
              m++;
              indicador = 1;
              if(m==100){
                break;
              }
            }
            if (indicador == 1){
              indiceFinal = m-1;
              indiceCentral = (indiceInicial+indiceFinal)/2;
              listaDistancias.add(indiceCentral);
              listaMedidas.add(contadorMedidas);
              
              for(int l=0; l<listaMedidas.size(); l++){
                if (listaMedidas.get(l) <= 2){
                  listaMedidas.remove(l);
                  listaDistancias.remove(l);
                }
              }
              
              contadorMedidas=0;
              indicador = 0;
            }
            
          }
          
          numObj = 0;
          
          for (int p=0;p<listaMedidas.size();p++){
            
            numObj += float(listaMedidas.get(p))/(float((112-(11/10)*listaDistancias.get(p))));
            print("\n Número de objetos sem arredondamento:"+numObj); 
            numObj = Math.round(numObj);
            print("\n Número de objetos com arredondamento:"+numObj);
          }
          
          print("\n Lista de distâncias: "+listaDistancias);
          print("\n Lista de medidas:    "+ listaMedidas);
          
          listaDistancias.clear();
          listaMedidas.clear();
          
          if (int(numObj) < 2){
            text = defaultText;
          }
        
          else{
            problemText = "CUIDADO !!!                                           EXISTEM " + int(numObj) + " OBJETOS NO NOSSO CAMPO DE VISÃO !!!";
            text = problemText;
          }
          
          
          TableRow newRow = table.addRow();
          newRow.setString("Horário", java.time.LocalDateTime.now().toString());
          newRow.setInt("Objetos", int(numObj));
          saveTable(table, "lidar_log.csv");
          
      }
    }
        
     if (medidasRecebidas.size() == 128){
        medidasRecebidas.clear();
        if (modoDebug == 0){
          angulosRecebidos.clear(); //está comentada por conta dos testes, na prática deve ser descomentada!
        }
        if(modoDebug == 1){
          Collections.reverse(angulosRecebidos); //utilizado apenas para testes, na prática deve ser comentada!
        }
      }
      
     for (int i=0; i<medidasPorAngulos.length; i++){
       medidasPorAngulos[i]=0;
     }
    
    popMatrix();
}

// funcao drawText()
void drawText() {
  
    pushMatrix();
    fill(0,0,0);
    noStroke();
    rect(0, 481, width, 540);
    textSize(25);
    if (text == defaultText){
      fill(255,255,255);
    }
    else{
      fill(255,0,0);
    }
    // imprime dados do sonar
    text(text,50, 525);
    textSize(18);
    popMatrix(); 
}

void serialEvent (Serial myPort) { 
    // inicia leitura da porta serial
    try {
        // leitura de dados da porta serial ate o caractere '#' na variavel data
        data = myPort.readStringUntil('#');
        //print(data);  // imprime "data" (debug)
        // remove caractere final '#'
        data = data.substring(0,data.length()-1); 
        // encontra indice do caractere ',' e guarda em "index1" 
        index1   = data.indexOf(",");
        // le dados da posicao 0 ate a posicao index1 e guarda em "angle"
        angle    = data.substring(0, index1);
        // le dados da posicao "index+1 ate o final e guarda em "distance"
        distance = data.substring(index1+1, data.length()); 
        //println(" -> angle= " + angle + " distance= " + distance);

        // converte variaveis tipo String para tipo inteiro
        iAngle    = int(angle);    // angulo em graus
        iDistance = int(distance); // distancia em cm
        //println("angulo= " + iAngle + "° distancia= " + iDistance + "cm");
        
        medidasRecebidas.add(iDistance);
        if(modoDebug == 0){
          angulosRecebidos.add(iAngle);
        }
        
    }
    catch(RuntimeException e) {
        e.printStackTrace();
    }
}

// funcao keyPressed
// processa tecla acionada (envia para a porta serial)
void keyPressed() {
    
  if (key == 's'){
    medidasRecebidas.clear();
    angulosRecebidos.clear();
  }
    whichKey = key;
    myPort.write(key);
    println("");
    println("Enviando tecla '" + key + "' para a porta serial. ");
}

void testarValores(){

  if(medidasRecebidas.size()<5){
    medidasRecebidas.add(100);
  }
  else if (medidasRecebidas.size()>=5 && medidasRecebidas.size()<8){
    medidasRecebidas.add(90);
  }
  else if (medidasRecebidas.size()>=8 && medidasRecebidas.size()<20){
    medidasRecebidas.add(91);
  }  
  else if (medidasRecebidas.size()>=20 && medidasRecebidas.size()<24){
    medidasRecebidas.add(93);
  }
  else if (medidasRecebidas.size()>=24 && medidasRecebidas.size()<50){
    medidasRecebidas.add(95);
  }
  else if (medidasRecebidas.size()>=50 && medidasRecebidas.size()<110){
    medidasRecebidas.add(18);
  }
  else if (medidasRecebidas.size()>=110 && medidasRecebidas.size()<128){
    medidasRecebidas.add(100);
  }
  
}
