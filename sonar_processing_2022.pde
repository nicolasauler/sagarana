// bibliotecas
import processing.serial.*;      // importa biblioteca de comunicacao serial
import java.awt.event.KeyEvent;  // importa biblioteca para leitura de dados da porta serial
import java.io.IOException;
import java.util.*;
import java.util.Arrays;
import java.util.List;

// interface serial
Serial myPort; // definicao do objeto serial

//  ======= CONFIGURACAO SERIAL ==================

    String   porta= "COM5";  // <== acertar valor ***
    int   baudrate= 115200;  // 115200 bauds
    char    parity= 'N';     // sem paridade
    int   databits= 8;       // 8 bits de dados
    float stopbits= 2.0;     // 2 stop bits

//  ==============================================

// variaveis
String angle=""; //valor do ângulo
String distance=""; // valor da distância
String data=""; //ângulo,distância#
String noObject; //diz se o objeto foi detectado ou não
float  pixsDistance;
int    iAngle, iDistance;
int    index1=0; //posicao para limitar o valor do angulo
int    index2=0; //posicao para limitar o valor de distancia
int larguraObjeto = 0;
String text = "";
String defaultText = "SAGARANA                                                                                                      TURMA 1 - BANCADA A6";
String problemText = "CUIDADO !!!                               HÁ MAIS DE UM OBJETO NO NOSSO CAMPO DE VISÃO !!!";

// array com medidas reais
ArrayList<Integer> medidasRecebidas = new ArrayList<Integer>();
ArrayList<Integer> angulosRecebidos = new ArrayList<Integer>(Arrays.asList(20,21,22,23,24,25,26,27,28,29,31,32,33,34,35,36,37,38,39,41,42,44,45,46,47,48,59,51,52,53,54,55,56,57,58,59,61,62,63,64,65,66,67,68,69,71,72,73,74,75,76,77,78,79,81,82,83,84,85,86,87,88,89,91,92,93,94,95,96,97,98,99,101,102,103,104,105,106,107,108,109,111,112,113,114,115,116,117,118,119,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,149,141,142,143,144,145,146,147,148,149,151,152,153,154,155,156,157,158,159,160));

// keystroke
int whichKey = -1;  // variavel mantem tecla acionada
PImage img;


// ========================================================================
// funcao setup()
// ========================================================================
void setup() {
    size (960, 600);
    text = defaultText;
    smooth();
    img = loadImage("alerta.png");
    // interface serial
    //myPort = new Serial(this, porta, baudrate, parity, databits, stopbits);  // inicia comunicacao serial 
    // leitura de dados da porta serial até o caractere '#' (para leitura de "angulo,distancia#"
    //myPort.bufferUntil('#'); 

}

// ========================================================================
// funcao draw
// ========================================================================
void draw() {
    iDistance = iDistance+1;
    if(iDistance > 40){
      iDistance = 0;
    }
    pushMatrix();
    translate(0,40);
    fill(98,245,31);
    noStroke();
    fill(255,255,255);
    rect(0, -40, width, 480+40);
    // chama funcoes para desenhar o sonar
    drawRadar();
    drawObject(); //chamar na função do serial?
    drawText();
    popMatrix();
}

// funcao drawRadar()
void drawRadar() {
    if (larguraObjeto >= 34){
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
    arc(0,0,800,800,10*PI/9,17*TWO_PI/18);
    arc(0,0,600,600,10*PI/9,17*TWO_PI/18);
    arc(0,0,400,400,10*PI/9,17*TWO_PI/18);
    arc(0,0,200,200,10*PI/9,17*TWO_PI/18);
    line(0,0,375.87704,-136.80809);
    line(0,0,-375.87704,-136.80809);
    popMatrix();
}

// funcao drawObject()
void drawObject() {
  
  InterfaceReal();
  delay(25);
  
}

void testarValores(){

  
  if(medidasRecebidas.size()<10){
    medidasRecebidas.add(45);
  }
  
  else if (medidasRecebidas.size()>=10 && medidasRecebidas.size()<50){
    medidasRecebidas.add(18);
  }
  
  else if (medidasRecebidas.size()>=50 && medidasRecebidas.size()<78){
    medidasRecebidas.add(42);
  }
  
  else if (medidasRecebidas.size()>=78 && medidasRecebidas.size()<118){
    medidasRecebidas.add(18);
  }
  
  else if (medidasRecebidas.size()>=118 && medidasRecebidas.size()<128){
    medidasRecebidas.add(45);
  }
  
}

void InterfaceReal(){
  
    testarValores();
    
    pushMatrix();
    translate(480,480);
    strokeWeight(15); 
    stroke(80,80,80); // azul
    // calcula distancia em pixels
    pixsDistance = iDistance*10.0; 
    // limita faixa de apresentacao
    if(iDistance <= 40) {
        // desenha objeto        
        point(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)));
        strokeWeight(5);
    }
    
    for (int i=0; i < medidasRecebidas.size(); i++) {
      
        if (medidasRecebidas.get(i) > 40){
            medidasRecebidas.set(i,40);
        }
        
        pixsDistance = medidasRecebidas.get(i)*10.0;
        iAngle = angulosRecebidos.get(i);
        
        line(0,0,pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)));
        
        
        if (i == 127){
        
          for (int j=0; j < i; j++){
            if (medidasRecebidas.get(j) >= 17 && medidasRecebidas.get(j) <= 23){
              larguraObjeto = larguraObjeto + 1;
            }
            if (j==26 && larguraObjeto < 34){
              larguraObjeto = 0;
              text = defaultText;
            }
            else if (j==26 && larguraObjeto >=34){
              larguraObjeto = 0;
              text = problemText;
            }
          }
        }
    }
    
    //largura de 1 objeto = 20cm
      
     if (medidasRecebidas.size() == 128){
        medidasRecebidas.clear();
        //angulosRecebidos.clear();
        Collections.reverse(angulosRecebidos);
      }
    
    popMatrix();
}

// funcao drawText()
void drawText() {
  
    pushMatrix();
    // limita detecao de objetos a 100 cm
    if(iDistance > 100) {
        noObject = "Não Detectado";
    }
    else {
        noObject = "Detectado";
    }
    fill(0,0,0);
    noStroke();
    rect(0, 481, width, 540);
    textSize(12);
    if (larguraObjeto >= 34){
      fill(255,255,255);
    }
    else{
      fill(0,0,0);
    }
    text("10cm",590,470);
    text("20cm",690,470);
    text("30cm",790,470);
    text("40cm",890,470);
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

// ========================================================================
// funcoes para conexao com a porta serial
// ========================================================================

void serialEvent (Serial myPort) { 
    // inicia leitura da porta serial
    try {
        // leitura de dados da porta serial ate o caractere '#' na variavel data
        data = myPort.readStringUntil('#');
        print(data);  // imprime "data" (debug)
        // remove caractere final '#'
        data = data.substring(0,data.length()-1); 
        // encontra indice do caractere ',' e guarda em "index1" 
        index1   = data.indexOf(",");
        // le dados da posicao 0 ate a posicao index1 e guarda em "angle"
        angle    = data.substring(0, index1);
        // le dados da posicao "index+1 ate o final e guarda em "distance"
        distance = data.substring(index1+1, data.length()); 
        println(" -> angle= " + angle + " distance= " + distance);

        // converte variaveis tipo String para tipo inteiro
        iAngle    = int(angle);    // angulo em graus
        iDistance = int(distance); // distancia em cm
        println("angulo= " + iAngle + "° distancia= " + iDistance + "cm");
        
        medidasRecebidas.add(iDistance);
        angulosRecebidos.add(iAngle);
        
    }
    catch(RuntimeException e) {
        e.printStackTrace();
    }
}

// funcao keyPressed
// processa tecla acionada (envia para a porta serial)
void keyPressed() {
    whichKey = key;

    myPort.write(key);
    println("");
    println("Enviando tecla '" + key + "' para a porta serial. ");
}
