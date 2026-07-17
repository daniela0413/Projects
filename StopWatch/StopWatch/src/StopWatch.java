import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Time;

public class StopWatch implements ActionListener {

    ImageIcon icon;
   JFrame frame=new JFrame();
    JButton startButton=new JButton("Start");
    JButton resetButton=new JButton("Reset");
    JLabel timeLabel=new JLabel();
    int elapsedTime=0;
    int seconds=0;
    int minutes=0;
    int hours=0;
    boolean stared=false;
    String secondsString=String.format("%02d",seconds);
    String minutsString=String.format("%02d",minutes);
    String hoursString=String.format("%02d",hours);

    Timer timer=new Timer(1000, new ActionListener() {
        @Override
        public void actionPerformed(ActionEvent e) {
            elapsedTime+=1000;
            hours=(elapsedTime/3600000);
            minutes=(elapsedTime/60000)%60;
            seconds=(elapsedTime/1000)%60;
            secondsString=String.format("%02d",seconds);
            minutsString=String.format("%02d",minutes);
            hoursString=String.format("%02d",hours);
            timeLabel.setText(hoursString+":"+minutsString+":"+secondsString);

        }
    });

    StopWatch(){

        icon = new ImageIcon(new ImageIcon("image.png").getImage().getScaledInstance(50, 50, Image.SCALE_SMOOTH));

        timeLabel.setText(hoursString+":"+minutsString+":"+secondsString);
        timeLabel.setBounds(100,100,200,100);
        timeLabel.setFont(new Font("Cambria",Font.ITALIC,35));
        timeLabel.setBorder(BorderFactory.createBevelBorder(1));
        timeLabel.setOpaque(true);
        timeLabel.setHorizontalAlignment(JTextField.CENTER);


        startButton.setBounds(100,200,100,50);
        startButton.setFont(new Font("Arial",Font.ITALIC,20));
        startButton.setFocusable(false);
        startButton.addActionListener(this);

        resetButton.setBounds(200,200,100,50);
        resetButton.setFont(new Font("Arial",Font.ITALIC,20));
        resetButton.setFocusable(false);
        resetButton.addActionListener(this);


        frame.setIconImage(icon.getImage());
        frame.add(timeLabel);
        frame.add(startButton);
        frame.add(resetButton);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(420,420);
        frame.setLayout(null);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }



    @Override
    public void actionPerformed(ActionEvent e) {
        if(e.getSource()==startButton){
            if (stared==false) {
                stared=true;
                startButton.setText("Stop");
                start();
            }else {
                stared=false;
                startButton.setText("Start");
                stop();
            }
        }

        if(e.getSource()==resetButton){
            stared=false;
            startButton.setText("Start");
            reset();
        }

    }

    void start(){
        timer.start();
    }

    void stop(){
        timer.stop();

    }

    void reset(){

        timer.stop();
        elapsedTime=0;
        seconds=0;
        minutes=0;
        hours=0;
        secondsString=String.format("%02d",seconds);
        minutsString=String.format("%02d",minutes);
        hoursString=String.format("%02d",hours);
        timeLabel.setText(hoursString+":"+minutsString+":"+secondsString);


    }

}
