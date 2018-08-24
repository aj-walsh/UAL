PFont sourceCode;

String[] inputLetters = {"a", "b", "c", "d", "e"};
int letterCount = inputLetters.length;
IntDict[] firstLetterArray = new IntDict[letterCount];
int dictSize;

String[][] keys;
int[][] values;

int tileCountX = letterCount;
int tileCountY = 30;
int tileWidth, tileHeight;

void setup()  {
  size(750, 1000);
  background(255);
  fill(0);
  sourceCode = createFont("SourceCodePro-Regular", 10);
  textFont(sourceCode);
  getTiles();
  assignWords();
  sortWords();
  visualise();
}

void draw()  {
}

void getTiles()  {
  tileWidth = width/tileCountX;
  tileHeight = (height-50)/tileCountY;
}

void assignWords()  {
  // Load the text, conjoin it, then seperate the words into an array of strings.
  String[] lines = loadStrings("Breadboard.txt");
  String joinedText = join(lines, " ");
  String[] words = splitTokens(joinedText, " 0123456789.,;:?!_-—()\"");
  for (int i = 0; i < firstLetterArray.length; i++)  {
    firstLetterArray[i] = new IntDict();
  }
  
  for (int currentWord = 0; currentWord < words.length; currentWord++)  {
    words[currentWord] = words[currentWord].toLowerCase();
    for (int x = 0; x < letterCount; x++)  {
      String firstLetter = str(char(x+97));
      if (words[currentWord].startsWith(firstLetter))  {
        firstLetterArray[x].increment(words[currentWord]);
      }
    }
  }
}

void sortWords()  {
  for (int i = 0; i < letterCount; i++)  {
    firstLetterArray[i].sortKeysReverse();
    firstLetterArray[i].sortValuesReverse();
  }
}

void visualise()  {  
  // Assigning Values.
  for (int gridX = 0; gridX < letterCount; gridX++)  {
    dictSize = firstLetterArray[gridX].size();
    keys = new String[letterCount][dictSize];
    values = new int[letterCount][dictSize];
    keys[gridX] = firstLetterArray[gridX].keyArray();
    values[gridX] = firstLetterArray[gridX].valueArray();
    for (int gridY = 0; gridY < keys[gridX].length; gridY++)  {
      int textSize = int(constrain(values[gridX][gridY], 5, 23.5));
      textSize(textSize);
      text(keys[gridX][gridY], gridX*tileWidth + 10, gridY*tileHeight+tileHeight + 10);
    }
  }
}
