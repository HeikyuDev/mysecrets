import 'dart:math';

import 'password_generator.dart';

/// Compact offline wordlist. NOTE: entropy per word is lower than the classic
/// 7776-word EFF diceware list; the entropy meter reports the honest value for
/// this actual list size.
const passphraseWords = [
  'amber','anchor','apple','arrow','aurora','autumn','badge','bamboo',
  'banjo','basil','battery','beacon','bicycle','birch','bishop','blaze',
  'blossom','bolt','boulder','bramble','bridge','bronze','brook','bubble',
  'cactus','canyon','cedar','cinder','cinnamon','cobalt','compass','copper',
  'coral','cosmos','crater','crescent','crimson','dawn','delta','denim',
  'desert','diamond','dolphin','driftwood','dune','echo','eagle','ember',
  'engine','emberlin','falcon','fern','fjord','flint','forest','fossil',
  'fountain','frost','gadget','galaxy','garnet','geyser','ginger','glacier',
  'granite','grove','hammock','harbor','harvest','hazel','helix','hollow',
  'horizon','indigo','iris','ivory','jaguar','jasmine','jetty','jungle',
  'kayak','kernel','kestrel','lagoon','lantern','lattice','ledger','lemon',
  'lighthouse','lily','linen','lotus','lumber','lunar','mahogany','mango',
  'maple','marble','meadow','mercury','meteor','mirror','monsoon','moon',
  'moss','nebula','nectar','nimbus','nomad','north','oasis','ocean',
  'onyx','opal','orbit','orchid','otter','oxide','palm','panther',
  'pebble','pepper','phoenix','piano','pilot','pine','pirate','planet',
  'plateau','poppy','prairie','prism','puma','pulse','quartz','quill',
  'rain','raven','reef','rhythm','ridge','rifle','river','rocket',
  'rust','saffron','sage','sail','salmon','sandal','sapphire','scarf',
  'shale','shell','shimmer','signal','silver','sky','smoke','snorkel',
  'solar','sonnet','spark','sphere','spiral','spruce','star','stone',
  'stream','summit','sunset','surf','swamp','tandem','teak','thistle',
  'thunder','tide','timber','topaz','torch','totem','trail','tulip',
  'tundra','turbine','twine','valley','vanilla','velvet','vertex','vine',
  'violet','voyage','walnut','wander','wave','willow','window','wolf',
  'wombat','yarn','yonder','zenith',
];

class PassphraseGenerator {
  static final _secure = Random.secure();
  static const defaultSeparator = '-';

  static String generate({int words = 5, String separator = defaultSeparator}) {
    if (words < 3 || words > 8) {
      throw ArgumentError.value(words, 'words', 'must be between 3 and 8');
    }
    final picked =
        List.generate(words, (_) => passphraseWords[_secure.nextInt(passphraseWords.length)]);
    return picked.join(separator);
  }

  static double entropyBitsPerWord() => log(passphraseWords.length) / ln2;

  static double entropyBits(int words) =>
      words * (log(passphraseWords.length) / ln2);

  static StrengthLabel labelFor(double bits) =>
      PasswordGenerator.labelFor(bits);
}
