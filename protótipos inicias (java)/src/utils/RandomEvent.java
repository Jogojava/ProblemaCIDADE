package utils;

import game.GameState;

import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;

public class RandomEvent {

    private static final Random random = new Random();

    public static void triggerEvent(int chance, String message) {
        int roll = random.nextInt(100) + 1;

        if (roll <= chance) {
            System.out.println(message);
        }
    }

    public static void eventTimer(int chance, String message, Timer timer) {

        // Timer de 2m para evento aleatório de 10%
        timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    if (GameState.canTriggerEvent) {
                        RandomEvent.triggerEvent(10, "Evento raro! (10%)");
                    }
                }
            }, 0, 1000);
        }

    public static void eventTimerStop(Timer timer) {
        timer.cancel();
    }
}