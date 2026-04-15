package utils;

import java.util.Random;

public class RandomEvent {

    private static final Random random = new Random();

    public static String tryTriggerEvent(int chance, String message) {
        int roll = random.nextInt(100) + 1;

        if (roll <= chance) {
            return message;
        }

        return null;
    }
}