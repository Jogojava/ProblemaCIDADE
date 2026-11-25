package game;

import java.util.Scanner;

public class GameUI {
    public static void showWelcome(Scanner sc) {
        GameState.canTriggerEvent = false;
        try {
            System.out.println("\nBem-vindo ao jogo!");
            sc.nextLine();
        } finally {
            GameState.canTriggerEvent = true;
        }
    }

    public static boolean shouldExit(Scanner sc) {
    GameState.canTriggerEvent = false;
    try {
        while (true) {
            System.out.print("\nVocê deseja mesmo sair do jogo? (S/N)\n-> ");
            String userExit = sc.nextLine();

            if (userExit.equalsIgnoreCase("S")) {
                return true;
            } else if (userExit.equalsIgnoreCase("N")) {
                return false;
            } else {
                System.out.println("Entrada inválida. Digite S ou N.");
            }
        }
    } finally {
        GameState.canTriggerEvent = true;
    }
}
}