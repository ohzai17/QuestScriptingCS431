# NPC Quest Script for EQEmu
# Author: [Your Name]
# YouTube Demo: [Insert Link Here]

# Zone: poknowledge
# NPC: npcname


sub EVENT_SAY {
    if ($text=~/Hail/i) {
        plugin::Whisper("Greetings, adventurer! I can help you with [Level Up], [AA Experience], [Summon Items], [Buffs], or [Teleportation]. What do you need?");
    }
    elsif ($text=~/Level Up/i) {
        plugin::Whisper("Hand me 10,000 platinum, and I will grant you a level.");
    }
    elsif ($text=~/AA Experience/i) {
        plugin::Whisper("If you are level 52 or higher, hand me 1,000 platinum, and I will grant you alternate advancement experience.");
    }
    elsif ($text=~/Summon Items/i) {
        plugin::Whisper("Hand me a Diamond, and I will summon an item of your choice. Use [#finditem] to get the item ID.");
    }
    elsif ($text=~/Buffs/i) {
        plugin::Whisper("I can cast beneficial buffs on you. Just say [Strength Buff], [Haste Buff], or [Regen Buff].");
    }
    elsif ($text=~/Teleportation/i) {
        plugin::Whisper("I can teleport you to [Plane of Knowledge], [Guild Lobby], or [Nexus]. Where would you like to go?");
    }
    elsif ($text=~/Strength Buff/i) {
        $npc->CastSpell(258, $client->GetID()); # Example: Strength of Earth
    }
    elsif ($text=~/Haste Buff/i) {
        $npc->CastSpell(278, $client->GetID()); # Example: Alacrity
    }
    elsif ($text=~/Regen Buff/i) {
        $npc->CastSpell(1058, $client->GetID()); # Example: Regeneration
    }
    elsif ($text=~/Plane of Knowledge/i) {
        $client->MovePC(202, 0, 0, 0, 0); # Teleport to Plane of Knowledge
    }
    elsif ($text=~/Guild Lobby/i) {
        $client->MovePC(344, 0, 0, 0, 0); # Teleport to Guild Lobby
    }
    elsif ($text=~/Nexus/i) {
        $client->MovePC(152, 0, 0, 0, 0); # Teleport to Nexus
    }
}

sub EVENT_ITEM {
    if (plugin::check_handin(\%itemcount, 1000 => 1)) { # Diamond
        plugin::Whisper("Tell me the item ID you want me to summon.");
        quest::setglobal("summon_item_allowed", 1, 5, "F");
    }
    elsif (plugin::check_handin(\%itemcount, 0 => 10000)) { # 10,000 platinum
        $client->AddLevelBasedExp(1, 0); # Grant 1 level
        plugin::Whisper("You have gained a level!");
    }
    elsif ($client->GetLevel() >= 52 && plugin::check_handin(\%itemcount, 0 => 1000)) { # 1,000 platinum
        $client->AddAAPoints(10); # Grant 10 AA points
        plugin::Whisper("You have gained alternate advancement experience!");
    }
    else {
        plugin::return_items(\%itemcount); # Return unneeded items
        plugin::Whisper("I have no use for this, so I am returning it to you.");
    }
}

sub EVENT_SAY_GLOBAL {
    if ($qglobals{"summon_item_allowed"} && $text=~/(\d+)/) { # Item ID provided
        my $item_id = $1;
        quest::summonitem($item_id);
        plugin::Whisper("Here is the item you requested.");
        quest::delglobal("summon_item_allowed");
    }
}

# Creative functionality: NPC dances when hailed
sub EVENT_SIGNAL {
    if ($signal == 1) {
        $npc->DoAnim(58); # Dance animation
        plugin::Whisper("I love to dance!");
    }
}
