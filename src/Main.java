import entities.Player;
import utils.InputHandler;
import utils.RandomEvent;
import game.GameUI;
import game.GameState;

import java.util.Scanner;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

public class Main {
    public static void main (String[] args) {
        Scanner sc = new Scanner(System.in);
        Random random = new Random();
        Timer timer = new Timer();

        // Cria um objeto player na classe Player
        Player player = InputHandler.createPlayer(sc);
        player.printPlayerStats();

        // Timer de 2m para evento aleatório de 10%
        timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    if (GameState.canTriggerEvent) {
                        RandomEvent.triggerEvent(10, "Evento raro! (10%)");
                    }
                }
            }, 0, 1000);

        // Jogo
        while (true) {
            GameUI.showWelcome(sc);

            // Espaço eventos aleatórios
            boolean espaco = true;
            do {
                System.out.println("Tire um tempinho para descançar...");
                String input = sc.nextLine();
                if (input != null) {
                    espaco = false;
                }
            } while (espaco);


            if (GameUI.shouldExit(sc)) {
                timer.cancel();
                break;
            }
        }

        sc.close();
    }
}