##############################################################
# NPC Multifunction Quest Script
# Zone: examplezone
#
# This script implements an NPC that:
#   - Responds to "Hail" with clickable bracketed text for further interaction.
#   - Allows players to purchase a single level for 10,000 platinum.
#   - Offers alternate advancement/leadership experience if level >= 52 for a lower platinum cost.
#   - Summons an item for players who first turn in a Diamond and then request an item.
#   - Can cast beneficial buff spells upon request.
#   - Can port players to a guild lobby (or another designated zone).
#   - Additionally, tells a fun joke when asked.
#
# IMPORTANT: The NPC returns all items given that it does not need.
#
# Code Review & Demo Video: https://youtu.be/YourVideoLinkHere
# Group Members: MemberA, MemberB, MemberC
##############################################################

# Global hash to keep track of players that have turned in a Diamond 
# (allowing them to request an item summon).
my %allowed_summon = ();

# EVENT_SAY: handles text spoken by the player.
sub EVENT_SAY {
    my $name = $client->GetCleanName();
    my $text = lc($text);   # Make text lowercase for easier matching
    
    if ($text =~ /hail/i) {
        # Respond with clickable bracketed text.
        plugin::Whisper("Hello, $name! I am at your service. If you wish to [level up] for 10,000 platinum, get [alternate advancement] if you're level 52 or above, ask for a [buff], get [port] to the guild lobby, or even [hear a joke].");
    }
    elsif ($text =~ /level up/i) {
        plugin::Whisper("To level up, simply trade me exactly 10,000 platinum and I will grant you one level. (No extra coins will be used!)");
    }
    elsif ($text =~ /alternate advancement/i) {
        plugin::Whisper("Alternate advancement is available if you are level 52 or higher. Trade me 5,000 platinum and you'll gain alternate experience points.");
    }
    elsif ($text =~ /buff/i) {
        plugin::Whisper("I can cast a few buffs on you! Say [blessing] to receive a blessing, or [haste] to get a haste spell.");
    }
    elsif ($text =~ /blessing/i) {
        plugin::Whisper("Casting Blessing upon you!");
        # Replace 1234 with an actual spell ID for a beneficial buff.
        quest::castspell(1234, $client->GetID());
    }
    elsif ($text =~ /haste/i) {
        plugin::Whisper("Casting Haste upon you!");
        # Replace 1235 with an actual spell ID.
        quest::castspell(1235, $client->GetID());
    }
    elsif ($text =~ /port/i) {
        plugin::Whisper("I can port you to the guild lobby. Please trade me 2,000 platinum as the fee.");
    }
    elsif ($text =~ /joke/i) {
        # A creative extra feature
        plugin::Whisper("Why did the Adventurer cross the road? Because the quest was on the other side!");
    }
    elsif ($text =~ /request item/i) {
        # This request is allowed only if the player already turned in a Diamond.
        if (exists $allowed_summon{$client->GetID()}) {
            plugin::Whisper("Please tell me the name of the item you wish to be summoned (e.g., say [summon healing potion]).");
        }
        else {
            plugin::Whisper("I do not recall receiving a Diamond from you. Please trade me a Diamond first.");
        }
    }
    elsif ($text =~ /summon (.+)/i) {
        # Only perform an item summon if the player has turned in a Diamond.
        if (exists $allowed_summon{$client->GetID()}) {
            my $item_name = $1;
            # Use the EQEmu command #find item <item_name> in testing to get the item ID.
            # Here we assume you looked up the item and hard-code the ID (example: 56789).
            my $item_id = 56789;  # Replace this with the actual item ID for "$item_name"
            plugin::Whisper("Summoning your requested item: $item_name.");
            quest::summonitem($item_id);
            # Clear the flag so that a new Diamond is needed for another summon.
            delete $allowed_summon{$client->GetID()};
        }
        else {
            plugin::Whisper("I can’t summon items unless you've provided a Diamond first.");
        }
    }
}

# EVENT_ITEM: handles items (and coins) turned in by players.
sub EVENT_ITEM {
    # Check for exact platinum payment for level advancement.
    # EQ coins are delivered in variables: $copper, $silver, $gold, $platinum.
    if (($platinum == 10) && ($gold == 0) && ($silver == 0) && ($copper == 0)) {
        plugin::Whisper("Congratulations on leveling up!");
        # Example: increase experience or directly level up (depending on server functions)
        # quest::setlevel($client->GetLevel()+1); -- Uncomment if your server allows direct level setting.
    }
    # Check for alternate advancement purchase (only allowed if player is level 52 or higher).
    elsif (($client->GetLevel() >= 52) && (($platinum == 5) && ($gold == 0) && ($silver == 0) && ($copper == 0))) {
        plugin::Whisper("Alternate advancement granted. May your leadership shine!");
        # Apply alternate advancement here (for example, by giving a buff or adjusting experience)
        # You might add your own custom logic or call another function.
    }
    # Check for port fee (2,000 platinum). If so, teleport the client.
    elsif (($platinum == 2) && ($gold == 0) && ($silver == 0) && ($copper == 0)) {
        plugin::Whisper("Hold tight, I'll port you to the guild lobby!");
        # Example: Using quest::movepc to port player; update the zone ID and coordinates as needed.
        quest::movepc(10, 100, 100, 0);  # Replace 10 and coordinates with the proper values.
    }
    # Check if a Diamond is handed in. Assume the Diamond has an item ID of 106 (change as needed).
    elsif (plugin::check_handin(\%itemcount, 106 => 1)) {
        plugin::Whisper("A Diamond! You may now request an item to be summoned by saying 'request item'.");
        # Record that this client is allowed an item summon.
        $allowed_summon{$client->GetID()} = 1;
    }
    # (Optionally) Additional processing for buffs items or other trades can be added here.
    
    # Return any items or coins that are not needed or are in excess.
    plugin::return_items(\%itemcount);
}
