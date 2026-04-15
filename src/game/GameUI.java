package game;

import javax.swing.*;

import entities.Player;
import utils.RandomEvent;

import java.awt.*;

public class GameUI {

    private static JFrame frame;
    private static JPanel panel;

    private static javax.swing.Timer eventTimer;
    private static JLabel eventoLabel;

    public static void init() {
        frame = new JFrame("Meu Jogo");
        frame.setSize(400, 300);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        panel = new JPanel();
        panel.setLayout(null);

        frame.setContentPane(panel);
        frame.setVisible(true);
    }

    private static void clearScreen() {
        stopEventTimer(); // 🔥 importante
        panel.removeAll();
        panel.repaint();
    }

    // =========================
    // CRIAR PLAYER
    // =========================
    public static void showCreatePlayerScreen() {
        clearScreen();

        JLabel nameLabel = new JLabel("Apelido:");
        nameLabel.setBounds(50, 40, 100, 30);

        JTextField nameField = new JTextField();
        nameField.setBounds(150, 40, 150, 30);

        JLabel repLabel = new JLabel("Reputação (0-100):");
        repLabel.setBounds(50, 80, 150, 30);

        JTextField repField = new JTextField();
        repField.setBounds(200, 80, 100, 30);

        JButton criar = new JButton("Criar");
        criar.setBounds(130, 140, 120, 40);

        JLabel erro = new JLabel("");
        erro.setBounds(50, 180, 300, 30);
        erro.setForeground(Color.RED);

        criar.addActionListener(e -> {
            String name = nameField.getText();
            String repText = repField.getText();

            if (name.isBlank()) {
                erro.setText("Nome inválido!");
                return;
            }

            try {
                int rep = Integer.parseInt(repText);

                if (rep < 0 || rep > 100) {
                    erro.setText("Reputação deve ser 0-100!");
                    return;
                }

                Player player = new Player(name, rep);
                showPlayerStats(player);

            } catch (NumberFormatException ex) {
                erro.setText("Digite um número válido!");
            }
        });

        panel.add(nameLabel);
        panel.add(nameField);
        panel.add(repLabel);
        panel.add(repField);
        panel.add(criar);
        panel.add(erro);

        panel.revalidate();
        panel.repaint();
    }

    // =========================
    // STATS
    // =========================
    public static void showPlayerStats(Player player) {
        clearScreen();

        JLabel stats = new JLabel(
                "<html>Nome: " + player.getName() +
                "<br>Reputação: " + player.getReputation() + "</html>"
        );
        stats.setBounds(120, 60, 200, 60);

        JButton continuar = new JButton("Continuar");
        continuar.setBounds(130, 140, 120, 40);

        continuar.addActionListener(e -> showRestScreen());

        panel.add(stats);
        panel.add(continuar);

        panel.revalidate();
        panel.repaint();
    }

    // =========================
    // DESCANSO + EVENTOS
    // =========================
    public static void showRestScreen() {
        clearScreen();

        JLabel label = new JLabel("Tire um tempinho para descansar...");
        label.setBounds(80, 30, 300, 30);

        eventoLabel = new JLabel("");
        eventoLabel.setBounds(80, 60, 300, 30);
        eventoLabel.setForeground(Color.BLUE);

        JButton continuar = new JButton("Continuar");
        continuar.setBounds(130, 100, 120, 40);

        JButton sair = new JButton("Sair");
        sair.setBounds(130, 160, 120, 40);
        sair.setBackground(Color.RED);
        sair.setForeground(Color.WHITE);

        continuar.addActionListener(e -> showRestScreen());

        sair.addActionListener(e -> {
            if (shouldExit()) {
                System.exit(0);
            }
        });

        panel.add(label);
        panel.add(eventoLabel);
        panel.add(continuar);
        panel.add(sair);

        panel.revalidate();
        panel.repaint();

        startEventTimer(); // 🔥 inicia eventos por tempo
    }

    // =========================
    // TIMER DE EVENTOS
    // =========================
    private static void startEventTimer() {
        stopEventTimer();

        eventTimer = new javax.swing.Timer(1000, e -> {
            String evento = RandomEvent.tryTriggerEvent(10, "✨ Evento raro apareceu!");

            if (evento != null) {
                eventoLabel.setText(evento);
            }
        });

        eventTimer.start();
    }

    private static void stopEventTimer() {
        if (eventTimer != null) {
            eventTimer.stop();
        }
    }

    // =========================
    // SAÍDA
    // =========================
    public static boolean shouldExit() {
        int resposta = JOptionPane.showConfirmDialog(
                frame,
                "Você deseja mesmo sair do jogo?",
                "Confirmação",
                JOptionPane.YES_NO_OPTION
        );

        return resposta == JOptionPane.YES_OPTION;
    }
}