package utils;

import entities.Player;

import java.util.Scanner;

public class InputHandler {
    public static Player createPlayer() {
        Scanner sc = new Scanner(System.in);

        String name = getUserName(sc);
        int reputation = getUserReputation(sc);

        return new Player(name, reputation);
    }

    private static String getUserName(Scanner sc) {
        String userName;
        boolean loop;

        do {
            System.out.print("\nApelido\n-> ");
            userName = sc.nextLine();

            if (userName.isBlank()) {
                System.out.println("Digite um apelido válido!");
                loop = true;
            } else {
                loop = false;
            }
        } while(loop);
        
        return userName;
    }

    private static int getUserReputation(Scanner sc) {
        int reputation = 0;

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

        return reputation;
    }
}