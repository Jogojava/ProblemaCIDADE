package utils;

import entities.Player;

import javax.swing.JOptionPane;

public class InputHandler {
    public static Player createPlayer() {

    String name;
    do {
        name = JOptionPane.showInputDialog("Digite seu apelido:");
        if (name == null) System.exit(0); // cancelou
    } while (name.isBlank());

    int reputation;
    while (true) {
        String input = JOptionPane.showInputDialog("Reputação inicial (0-100):");

        if (input == null) System.exit(0);

        try {
            reputation = Integer.parseInt(input);
            if (reputation >= 0 && reputation <= 100) {
                break;
            }
        } catch (NumberFormatException ignored) {}

        JOptionPane.showMessageDialog(null, "Valor inválido.");
    }

    return new Player(name, reputation);
    }
}