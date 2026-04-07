package utils;

import entities.Player;

import java.util.Scanner;

public class InputHandler {
    public static Player createPlayer(Scanner sc) {
        boolean loop = false;
        String name;
        int reputation = 0;

        do {
            System.out.print("\nApelido\n-> ");
            name = sc.nextLine();

            if (name.isBlank()) {
                System.out.println("Digite um apelido válido!");
                loop = true;
            } else {
                loop = false;
            }
        } while(loop);

        while (true) {
            System.out.print("\nReputação inicial (0-100)\n-> ");
            String line = sc.nextLine();

            if (line.isBlank()) {
                System.out.println("Digite algum número.");
                continue;
            }

            try {
                reputation = Integer.parseInt(line);

                if (reputation >= 0 && reputation <= 100) {
                    break;
                } else {
                    System.out.println("Número fora do intervalo.");
                }
            } catch (NumberFormatException e) {
                System.out.println("Entrada inválida. Digite um número.");
            }
        }

        return new Player(name, reputation);
    }
}