import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Interface {

    public static void main(String[] args) {
        // Criando a janela
        JFrame frame = new JFrame("Minha Interface");
        frame.setSize(400, 300);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(null); // Layout livre

        // Criando o botão
        JButton botaoSair = new JButton("Sair");
        botaoSair.setBounds(150, 100, 100, 40);

        // Cor vermelha
        botaoSair.setBackground(Color.RED);
        botaoSair.setForeground(Color.WHITE);
        botaoSair.setFocusPainted(false);

        // Ação do botão (fechar o programa)
        botaoSair.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                System.exit(0);
            }
        });

        // Adicionando o botão na tela
        frame.add(botaoSair);

        // Tornando visível
        frame.setVisible(true);
    }
}