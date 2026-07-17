import javax.swing.*;
import java.awt.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;

public class MyFrame extends JFrame {

    ImageIcon image;
    Calendar calendar;
    SimpleDateFormat timeFormat;
    SimpleDateFormat dayFormat;
    SimpleDateFormat dateFormat;
    JLabel timeLabel;
    JLabel dayLabel;
    JLabel dateLabel;
    String time;
    String day;
    String date;

    MyFrame(){

        image=new ImageIcon("clock.png");

        timeFormat=new SimpleDateFormat("hh:mm:ss a");
        dayFormat=new SimpleDateFormat("EEEE");
        dateFormat=new SimpleDateFormat("dd MMMMM,yyyy");
        timeLabel=new JLabel();
        dayLabel=new JLabel();
        dateLabel=new JLabel();

        timeLabel.setFont(new Font("Cambria", Font.ITALIC,50));
        timeLabel.setForeground(new Color(159,20,198));
        timeLabel.setBackground(new Color(255,198,255));
        timeLabel.setOpaque(true);

        dayLabel.setFont(new Font("Cambria", Font.ITALIC,20));
        dateLabel.setFont(new Font("Cambria", Font.ITALIC,20));




        this.add(timeLabel);
        this.add(dayLabel);
        this.add(dateLabel);
        this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        this.setTitle("My Clock Program");
        this.setIconImage(image.getImage());
        this.setLayout(new FlowLayout());
        this.setSize(350,200);
        this.setResizable(false);
        this.setLocationRelativeTo(null);
        this.setVisible(true);

        setTime();

    }

    public void setTime(){

        while(true){

            day=dayFormat.format(Calendar.getInstance().getTime());
            dayLabel.setText(day);

            time=timeFormat.format(Calendar.getInstance().getTime());
            timeLabel.setText(time);

            date=dateFormat.format(Calendar.getInstance().getTime());
            dateLabel.setText(date);

            try {
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }

        }
        }

}
