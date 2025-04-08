# Basic Hello World quest script for EQEmu

sub EVENT_SAY {
    if ($text=~/Hail/i) {
        plugin::Whisper("Hello, traveler! I am just a humble NPC here to say hi.");
    }
}
