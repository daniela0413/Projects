// Definirea pinilor pentru LED-uri si buzzer
const int greenLED = 12;   // LED verde pentru aer curat
const int yellowLED = 13;  // LED galben pentru aer mediu
const int redLED = 7;     // LED rosu pentru aer foarte poluat
const int buzzer = 10;     // Buzzer

void setup() {
  // Initializarea comunicarii seriale
  Serial.begin(9600);

  // Configurarea pinilor LED si buzzer ca iesiri
  pinMode(greenLED, OUTPUT);
  pinMode(yellowLED, OUTPUT);
  pinMode(redLED, OUTPUT);
  pinMode(buzzer, OUTPUT);
}

void loop() {
  // Citirea valorii de la senzorul de calitate a aerului
  int sensorValue = analogRead(A0);

  // Afisarea valorii citite in consola seriala
  Serial.print("Air Quality = ");
  Serial.print(sensorValue);
  Serial.print(" *PPM");
  Serial.println();

  // Resetarea LED-urilor si a buzzer-ului
  digitalWrite(greenLED, LOW);
  digitalWrite(yellowLED, LOW);
  digitalWrite(redLED, LOW);
  digitalWrite(buzzer, LOW);

  // Conditionarea LED-urilor si a buzzer-ului in functie de valoarea senzorului
  if (sensorValue < 300) {        // Aer curat
    digitalWrite(greenLED, HIGH);
  } else if (sensorValue < 600) { // Aer mediu
    digitalWrite(yellowLED, HIGH);
  } else {                        // Aer foarte poluat
    digitalWrite(redLED, HIGH);
    digitalWrite(buzzer, HIGH);   // Pornirea buzzer-ului
  }w

  // Pauza de 1 secunda inainte de urmatoarea citire
  delay(1000);
}
