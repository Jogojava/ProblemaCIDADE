import entities.Player;
import utils.InputHandler;
import utils.RandomEvent;
import game.GameUI;

import java.util.Scanner;
import java.util.Timer;

public class Main {
    public static void main (String[] args) {
        Scanner sc = new Scanner(System.in);
        Timer timer = new Timer();
        
        Player player = InputHandler.createPlayer();
        player.printPlayerStats();

        RandomEvent.eventTimer(10, "Evento Raro! (10%)", timer);

        GameUI.showWelcome(sc);

        // Jogo
        do {
            // Espaço eventos aleatórios (test)
            boolean espaco = true;
            do {
                System.out.println("\nTire um tempinho para descansar...");
                String input = sc.nextLine();
                if (input != null) {
                    espaco = false;
                }
            } while (espaco);

        } while (!GameUI.shouldExit(sc));

        RandomEvent.eventTimerStop(timer);
        sc.close();
    }
}