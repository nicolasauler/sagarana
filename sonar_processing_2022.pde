// bibliotecas
import processing.serial.*;      // importa biblioteca de comunicacao serial
import java.awt.event.KeyEvent;  // importa biblioteca para leitura de dados da porta serial
import java.io.IOException;

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
int y = 180;
PFont  orcFont; //fonte de texto
String text = "";
String defaultText = "SAGARANA                                                                                                      TURMA 1 - BANCADA A6";
String problemText = "CUIDADO !!!                               HÁ MAIS DE UM OBJETO NO NOSSO CAMPO DE VISÃO !!!";

ArrayList<Integer> medidas = new ArrayList<Integer>();
ArrayList<Integer> medidas2 = new ArrayList<Integer>();

// keystroke
int whichKey = -1;  // variavel mantem tecla acionada


// ========================================================================
// funcao setup()
// ========================================================================
void setup() {
    size (960, 600);
    //translate(0,20); 
    text = defaultText;
    smooth();
    
    //orcFont = loadFont("OCRAExtended-24.vlw");
    
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
    //textFont(orcFont);
    noStroke();
    fill(255,255,255);
    rect(0, -40, width, 480+40);

    // chama funcoes para desenhar o sonar
    drawRadar();
    drawObject();
    drawText();
    popMatrix();
}

// funcao drawRadar()
void drawRadar() {
    pushMatrix();
    translate(480,480);
    noFill();
  
    strokeWeight(1.5);
    //stroke(98,245,31);
    stroke(0,0,0);
    // arcos
    arc(0,0,800,800,PI,TWO_PI);
    arc(0,0,600,600,PI,TWO_PI);
    arc(0,0,400,400,PI,TWO_PI);
    arc(0,0,200,200,PI,TWO_PI);
    popMatrix();
}

// funcao drawObject()
void drawObject() {
    
    if(medidas.size()<60){
      medidas.add(40);
    }
    else if (medidas.size()>=60 && medidas.size()<80){
      medidas.add(20);
    }
    else if (medidas.size()>=80 && medidas.size()<180){
      medidas.add(40);
    }
    else{
      medidas.clear();
    }
    
    if(medidas2.size()<30){
      medidas2.add(40);
    }
    else if (medidas2.size()>=30 && medidas2.size()<50){
      medidas2.add(20);
    }
    else if (medidas2.size()>=50 && medidas2.size()<100){
      medidas2.add(40);
    }
    else if (medidas2.size()>=100 && medidas2.size()<120){
      medidas2.add(20);
    }
    else if (medidas2.size()>=120 && medidas2.size()<180){
      medidas2.add(40);
    }
 
    else{
      medidas.clear();
      medidas2.clear();
    }
    
    pushMatrix();
    translate(480,480);
    strokeWeight(15); 
    stroke(80,80,80); // azul
    // calcula distancia em pixels
    pixsDistance = iDistance*10.0; 
    // limita faixa de apresentacao
    if(iDistance < 50) {
        // desenha objeto        
        point(pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)));
        strokeWeight(5);
    }
    
    for (int i=0; i < medidas2.size(); i++) {
        pixsDistance = medidas2.get(i)*10.0;
        iAngle = i;
        line(0,0,pixsDistance*cos(radians(iAngle)),-pixsDistance*sin(radians(iAngle)));
        if (i == 179){
          for (int j=0; j < 180; j++){
            if (medidas2.get(j) >= 17 && medidas2.get(j) <= 23){
              larguraObjeto = larguraObjeto + 1;
              
            }
            else{
              text = defaultText;
            }
          }
        }
    }
       
    if (larguraObjeto >= 34){
      text = problemText;
      drawBadScreen();
      larguraObjeto = 0;
    }
   
    popMatrix();
}

void drawBadScreen(){
  print("Cuidado! Existe mais de um objeto no nosso campo de visão!!!");
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
    fill(0,0,0);
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

//void serialEvent (Serial myPort) { 
//    // inicia leitura da porta serial
//    try {
//        // leitura de dados da porta serial ate o caractere '#' na variavel data
//        data = myPort.readStringUntil('#');
//        print(data);  // imprime "data" (debug)
//        // remove caractere final '#'
//        data = data.substring(0,data.length()-1); 
//        // encontra indice do caractere ',' e guarda em "index1" 
//        index1   = data.indexOf(",");
//        // le dados da posicao 0 ate a posicao index1 e guarda em "angle"
//        angle    = data.substring(0, index1);
//        // le dados da posicao "index+1 ate o final e guarda em "distance"
//        distance = data.substring(index1+1, data.length()); 
//        println(" -> angle= " + angle + " distance= " + distance);

//        // converte variaveis tipo String para tipo inteiro
//        iAngle    = int(angle);    // angulo em graus
//        iDistance = int(distance); // distancia em cm
//        println("angulo= " + iAngle + "° distancia= " + iDistance + "cm");
//    }
//    catch(RuntimeException e) {
//        e.printStackTrace();
//    }
//}

// funcao keyPressed
// processa tecla acionada (envia para a porta serial)
void keyPressed() {
    whichKey = key;

    myPort.write(key);
    println("");
    println("Enviando tecla '" + key + "' para a porta serial. ");
}
