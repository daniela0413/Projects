import java.util.*;

public class EncryptionProgram {

    private Scanner scanner;
    private Random random;
    private ArrayList<Character>list;
    private ArrayList<Character>shuffledList;
    private char character;//the starting position of the characters
    private String line;
    private char[] letters;



    EncryptionProgram(){
        scanner=new Scanner(System.in);
        random=new Random();
        list=new ArrayList<>();
        shuffledList=new ArrayList<>();
        character=' ';

        //automatically generating a new key for the user:
        newKey();
        //ask the user "what do you want to do":
        askQuestion();

    }

    //to ask questions:
   private void askQuestion(){

        while (true){
            System.out.println("******************************************************************************************************************");
            System.out.println("What do you want to do?");
            //give some instruction:
            System.out.println("Press (N) for New Key, press (G) for Get Key, press (E) for Encrypt, press (D) for Decrypt or press (Q) for Quit.");
            char response =Character.toUpperCase(scanner.nextLine().charAt(0));

            switch (response){
                case 'N' -> newKey();
                case 'G' -> getKey();
                case 'E' -> encrypt();
                case 'D' -> decrypt();
                case 'Q' -> quit();
                default -> System.out.println("Not a valid answer!");
            }
        }


    }

    //to generate a new key:
    private void newKey(){

        character= ' ';//32 in the table, so when we increment it actually move to the next character in the table
        list.clear();
        shuffledList.clear();
        for(int i=32;i<127;i++){
            list.add(Character.valueOf(character));//those are in order
            character++;
        }

        shuffledList=new ArrayList<>(list);//I did a copy because I don't want to change the original list
        //I want to shuffle this list:

        Collections.shuffle(shuffledList);
        System.out.println("A new key has been generated");


    }

    //to actually retrieve the key:
    private void getKey(){

        System.out.println("Key: ");
        for (Character x:list){
            System.out.print(x);
        }

        System.out.println();
        for(Character x: shuffledList){
            System.out.print(x);
        }
        System.out.println();

    }

    //to encrypt the message:
    private void encrypt(){
        //I ask for a message to encrypt and for every letter I will find where edges and at this same index within our shuffled list i"m going
        //to replace every letter

        System.out.println("Enter a message to be encrypted: ");
        String message=scanner.nextLine();
        letters=message.toCharArray();
        for(int i=0;i<letters.length;i++){
            for(int j=0;j<list.size();j++){
                if(letters[i]== list.get(j)){
                    letters[i]=shuffledList.get(j);
                    break;
                }
            }


        }

        System.out.println("Encrypted: ");
        for (char x: letters){
            System.out.print(x);
        }
        System.out.println();


    }

    //to decrypt a message:
    private void decrypt(){

        //but when the user generate a new key the shuffled will be different, so you can't longer decrypt your message

        System.out.println("Enter a message to be decrypted: ");
        String message=scanner.nextLine();
        letters=message.toCharArray();
        for(int i=0;i<letters.length;i++){
            for(int j=0;j<shuffledList.size();j++){
                if(letters[i]== shuffledList.get(j)){
                    letters[i]=list.get(j);
                    break;
                }
            }


        }

        System.out.println("Decrypted: ");
        for (char x: letters){
            System.out.print(x);
        }
        System.out.println();


    }




    //quit text at the program:
    private void quit(){

        System.out.println("Thank you, have a nice day!");
        System.exit(0);

    }



}

