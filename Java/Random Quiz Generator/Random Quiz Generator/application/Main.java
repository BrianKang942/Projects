package application;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Random;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.stage.Stage;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Button;
import javafx.scene.control.ComboBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.control.RadioButton;
import javafx.scene.control.SelectionMode;
import javafx.scene.control.TextField;
import javafx.scene.control.ToggleGroup;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.text.Text;

/**
 * 
 * @author aTeam87
 *
 */
public class Main extends Application {
  private ObservableList<String> topics; // list of topics
  private ArrayList<Question> questionBank; // list of questions
  private QuestionNode rootNode; // root question of quiz list
  private Scene mainMenu; // main menu scene
  private int numCorrect; // number of correctly answered questions after quiz
  private int quizSize; // size of current quiz

  // Global JavaFX Elements:
  private ListView topicSelection;
  private Label totalQuestions;

  /**
   * Builds the main menu of the Quiz Generator app
   *
   * @param primaryStage - Stage on which scenes will be displayed
   */
  @Override
  public void start(Stage primaryStage) {
    try {
      // Initialize all global variables
      this.totalQuestions = new Label();
      this.topicSelection = new ListView<String>();
      this.topics = FXCollections.observableArrayList();
      this.questionBank = new ArrayList<Question>();
      this.numCorrect = 0;
      this.quizSize = 0;
      this.rootNode = null;

      BorderPane root = new BorderPane();
      /**
       * TOP COMPONENT: DISPLAY TITLE
       */
      Label programTitle = new Label();
      programTitle.setText("QUIZ GENERATOR!!!");
      programTitle.setStyle("-fx-font-size: 30pt");

      /**
       * RIGHT COMPONENT: QUIZ
       */
      VBox rightControlBox = new VBox(); // outer container
      rightControlBox.setPadding(new Insets(10));
      rightControlBox.setSpacing(10);

      // First Child: Title label
      Label createQuiz = new Label("Create Quiz");
      createQuiz.setStyle("-fx-font-size: 15pt");

      // Second Child: Topic selection checklist
      this.topicSelection.getSelectionModel().setSelectionMode(SelectionMode.MULTIPLE);
      this.topicSelection.getItems().addAll(this.topics);

      // Third Child: Set number of questions to be quized
      TextField sizeOfQuiz = new TextField();
      sizeOfQuiz.setPromptText("Enter Size of Quiz");

      // Fourth Child: tip on using
      Text usageTip = new Text("*Hold [Command] down when selecting\n more than one topic.");

      // Fifth Child: Go button: navigates to quiz scene
      Button goToQuiz = new Button("GO!");
      goToQuiz.setOnAction(e -> {
        ObservableList<String> buffer = topicSelection.getSelectionModel().getSelectedItems();
        ArrayList<String> selectedTopics = new ArrayList<String>();
        for (int i = 0; i < buffer.size(); i++) {
          selectedTopics.add(buffer.get(i));
        }
        // Must select at least one topic
        if (selectedTopics.size() < 1) {
          alertDialogue(1);
        } else {
          // parse user input from string to integer
          try {
            this.quizSize = Integer.parseInt(sizeOfQuiz.getText().trim());
            // quiz size must be positive
            if (this.quizSize < 1) {
              alertDialogue(2);
            } else {
              setUpQuiz(selectedTopics, sizeOfQuiz.getText(), primaryStage);
            }
          } catch (NumberFormatException exception) {
            alertDialogue(3);
          }
        }
      });

      // Add all children to VBox
      rightControlBox.getChildren().addAll(createQuiz, usageTip, topicSelection, sizeOfQuiz,
          goToQuiz);

      /**
       * LEFT COMPONENT: MENU
       */
      VBox leftControlBox = new VBox(); // outer container
      leftControlBox.setPadding(new Insets(10));
      leftControlBox.setSpacing(10);

      // First child: Displays total number of questions in question bank
      Label totalQuestionsLabel = new Label("Total Questions: ");
      this.totalQuestions.setText("" + this.questionBank.size());

      // Second child: Navigation button takes user to questionForm
      Button navAddQuestionForm = new Button("Add New Question");
      navAddQuestionForm.setOnAction(e -> {
        primaryStage.setScene(new AddQuestionForm(this, primaryStage).getQuestionFormScene());
        totalQuestions.setText("" + this.questionBank.size());
      });

      // Third child: import controls for importing questions through json
      TextField importFileName = new TextField();
      importFileName.setPromptText("json filename for import");
      Button importButton = new Button("Import Questions");
      importButton.setOnAction(e -> {
        if (importFileName.getText().trim().isEmpty()) {
          alertDialogue(5);
        } else {
          importQuestions(importFileName.getText());
        }
      });

      // Fourth Child: Save to json file
      TextField exportFileName = new TextField();
      exportFileName.setPromptText("json filename for export");
      Button exportButton = new Button("Save Question To File");
      exportButton.setOnAction(e -> {
        if (exportFileName.getText().trim().isEmpty()) {
          alertDialogue(5);
        } else {
          saveToFile(exportFileName.getText());
        }

      });

      // Fifth Child: Exit
      Button quitProgram = new Button("Quit Quiz Generator");
      quitProgram.setOnAction(e -> primaryStage.close());

      // Add children to leftControlBox:
      leftControlBox.getChildren().add(new HBox(totalQuestionsLabel, totalQuestions));
      leftControlBox.getChildren().add(navAddQuestionForm);
      leftControlBox.getChildren().add(new VBox(importFileName, importButton));
      leftControlBox.getChildren().add(new VBox(exportFileName, exportButton));
      leftControlBox.getChildren().add(quitProgram);

      /**
       * CENTER COMPONENT: Question Mark Image
       */
      // FileInputStream imageInputFile;
      Image image = new Image("application/questionMark.jpg");
      ImageView imageView = new ImageView(image);

      imageView.setFitHeight(300);
      imageView.setFitWidth(200);

      /**
       * ADD COMPONENTS TO ROOT LAYOUT:
       */
      root.setTop(programTitle);
      root.setAlignment(programTitle, Pos.CENTER);
      root.setLeft(leftControlBox);
      root.setRight(rightControlBox);
      root.setCenter(imageView);

      /**
       * INSTANTIATE SCENE AND SET STAGE'S SCENE
       */
      this.mainMenu = new Scene(root, 800, 600);
      this.mainMenu.getStylesheets()
          .add(getClass().getResource("application.css").toExternalForm());
      primaryStage.setScene(this.mainMenu);
      primaryStage.show();

    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  /**
   * Given user submitted file name, attempts exporting questions to a json file.
   * 
   * @param jsonFileName
   */
  public void saveToFile(String jsonFileName) {
    // intializes the file object and main array
    JSONObject parsedFile = new JSONObject();
    JSONArray questionArray = new JSONArray();
    // for loop that iterates for topic, image, question, and choices
    for (int i = 0; questionBank.size() > i; i++) {
      JSONObject questionNode = new JSONObject();
      // puts the topic, image, and question into the node
      questionNode.put("questionText", questionBank.get(i).getQuestion());
      questionNode.put("topic", questionBank.get(i).getTopic());

      if (questionBank.get(i).getImage() == null) {
        questionNode.put("image", "none");
      } else {
        questionNode.put("image", questionBank.get(i).getImage());
      }


      JSONArray choiceArray = new JSONArray();
      // Second for loop that iterates for every choice and determines which one is correct
      for (int j = 0; questionBank.get(i).getChoices().size() > j; j++) {

        Map choiceNode = new LinkedHashMap(questionBank.get(i).getChoices().size());
        if (questionBank.get(i).getChoices().get(j).equals(questionBank.get(i).getAnswer())) {

          choiceNode.put("isCorrect", "T");
          choiceNode.put("choice", questionBank.get(i).getChoices().get(j));
        } else {
          choiceNode.put("isCorrect", "F");
          choiceNode.put("choice", questionBank.get(i).getChoices().get(j));

        }
        // adds it all to annother array 
        choiceArray.add(choiceNode);

      }
      // combines and puts topic, question, image, and choices 
      questionNode.put("choiceArray", choiceArray);
      questionArray.add(questionNode);
    }
    // the combination is then added into the question array 
    parsedFile.put("questionArray", questionArray);

    // writes the array into the JSON file/
    PrintWriter pw;
    try {
      pw = new PrintWriter(jsonFileName);
      pw.write(parsedFile.toJSONString());
      pw.flush();
      pw.close();
    } catch (FileNotFoundException e) {
      alertDialogue(7);
    }

  }

  /**
   * Given user submitted file name, attempts importing questions from a json file.
   * 
   * @param jsonFileName
   */
  public void importQuestions(String jsonFileName) {
    Object jsonFile;
    JSONObject parsedFile;
    JSONArray questionArray;

    try {
      jsonFile = new JSONParser().parse(new FileReader(jsonFileName));
      // Convert to JSONObject
      parsedFile = (JSONObject) jsonFile;
      // Extract question array
      questionArray = (JSONArray) parsedFile.get("questionArray");

      // add all questions from json to questionBank
      for (int i = 0; i < questionArray.size(); i++) {
        // current question
        JSONObject questionNode = (JSONObject) questionArray.get(i);
        String question = (String) questionNode.get("questionText");
        String topic = (String) questionNode.get("topic");
        String image = (String) questionNode.get("image");

        // change image to null if there is no image data
        if (image.equals("none")) {
          image = null;
        }

        // Extract choiceArray
        JSONArray choicesArray = (JSONArray) questionNode.get("choiceArray");
        ArrayList<String> choices = new ArrayList<String>();
        String answer = null;

        // Add all choices to choice array
        for (int j = 0; j < choicesArray.size(); j++) {
          // current choice 
          JSONObject choiceNode = (JSONObject) choicesArray.get(j);
          String isCorrect = (String) choiceNode.get("isCorrect");
          String choice = (String) choiceNode.get("choice");
          // if isCorrect field is T / true, set answer to current choice
          if (isCorrect.equals("T")) {
            answer = choice;
          }
          // add the current choice to choices array
          choices.add(choice);
        }
        // add current question to questionBank
        addQuestion(new Question(question, topic, answer, choices, image));
      }

    } catch (IOException e) {
      alertDialogue(4); // call helpful alert dialogure
    } catch (ParseException e) {
      alertDialogue(6); // call helpful alert dialogure
    }
  }

  /**
   * Given user topics and desired number of question, creates and initiates the quiz.
   */
  private void setUpQuiz(ArrayList<String> selectedTopics, String sizeOfQuiz, Stage primaryStage) {
    // quizQuestions is a list of possible questions for a quiz (determined by topic selection)
    ArrayList<Question> quizQuestions = new ArrayList<Question>();
    QuestionNode pointer; // used for creating the linked list of questions (quiz)
    Random random = new Random(); // used for randomly selecting questions to be added to quiz
    int counter = 0; // current number of questions in quiz

    // Add all questions from selected topics to quizQuestions list
    for (int i = 0; i < this.questionBank.size(); i++) {
      if (selectedTopics.contains(this.questionBank.get(i).getTopic())) {
        quizQuestions.add(this.questionBank.get(i));
      }
    }


    // randomly choose a root question to start the quis off
    int randomIndex = random.nextInt(quizQuestions.size());
    this.rootNode = new QuestionNode(quizQuestions.get(randomIndex), this, primaryStage);
    quizQuestions.remove(randomIndex);
    pointer = this.rootNode;
    counter++;

    // Add questions until counter equals determined quizsize or
    // available quiz questions are empty
    while (!quizQuestions.isEmpty() && counter < this.quizSize) {
      randomIndex = random.nextInt(quizQuestions.size());
      pointer.setNext(new QuestionNode(quizQuestions.get(randomIndex), this, primaryStage));
      quizQuestions.remove(randomIndex);
      pointer = pointer.getNext();
      counter++;
    }
    // if there are less available questions than quiz size, reset quiz size
    if (counter < this.quizSize) {
      this.quizSize = counter;
    }

    // set scene to root
    primaryStage.setScene(this.rootNode.getQuizDisplayScene());
  }

  /**
   * Used by AddQuestionForm to add a new question to the questionBank. Updates
   * 
   * @param newQuestion - new question to be added.
   */
  public void addQuestion(Question newQuestion) {
    // Add new question to the question bank
    this.questionBank.add(newQuestion);
    // If the topic is new, add it to the topic list

    // if(!this.topics.contains(newQuestion.getTopic())) {
    // this.topics.add(newQuestion.getTopic());
    // java.util.Collections.sort(this.topics);
    // }

    if (this.topics.size() == 0) {
      this.topics.add(newQuestion.getTopic());
    } else {
      // Alphabetically place topic into topic list
      if (!this.topics.contains(newQuestion.getTopic())) {
        for (int i = 0; i < this.topics.size(); i++) {
          if (newQuestion.getTopic().compareToIgnoreCase(this.topics.get(i)) < 0) {
            this.topics.add(i, newQuestion.getTopic());
            break;
          } else {
            continue;
          }
        }
      }
    }
    if (!this.topics.contains(newQuestion.getTopic())) {
      this.topics.add(newQuestion.getTopic());
    }

    // Update main menu displays that show dynamic data:
    this.topicSelection.setItems(this.topics);
    this.totalQuestions.setText("" + this.questionBank.size());
  }

  /**
   * Displays a dynamic alert dialogue box depending the input signal
   * 
   * @param warningType - signal that determines the text of the alert
   */
  public void alertDialogue(int warningType) {
    Alert alert = new Alert(AlertType.ERROR); // alert type should be error
    alert.setTitle("Input Error"); // All errors are the result of user input
    alert.setHeaderText(null);

    // depending on the warningType signal, a helpful message is displayed
    switch (warningType) {
      case 1:
        alert.setContentText("Select one or more topics to quiz from.");
        break;
      case 2:
        alert.setContentText("Size of quiz must be a positive integer.");
        break;
      case 3:
        alert.setContentText("Quiz size not a valid integer.");
        break;
      case 4:
        alert.setContentText("File does not exist. Check file path and spelling.");
        break;
      case 5:
        alert.setContentText("File name cannot be blank");
        break;
      case 6:
        alert.setContentText("Unable to parse file");
        break;
      case 7:
        alert.setContentText("Error with creating json file");
        break;
    }

    alert.showAndWait(); // show alert and wait until user clicks ok
  }

  /**
   * Getter for the mainMenu scene. Used by other classes for navigation back to scene.
   * 
   * @return mainMenu
   */
  public Scene getMainMenu() {
    return this.mainMenu;
  }

  /**
   * Increments the current number of correctly answered question in quiz.
   */
  public void incrementNumCorrect() {
    this.numCorrect++;
  }

  /**
   * Returns the current number of correctly answered questions in quiz.
   * 
   * @return numCorrect
   */
  public int getNumberCorrect() {
    return this.numCorrect;
  }

  /**
   * Returns the size of the current quiz.
   * 
   * @return quizSize
   */
  public int getSizeOfQuiz() {
    return this.quizSize;
  }

  /**
   * Resets the number of correct answers. Called following a quiz.
   */
  public void resetNumberCorrect() {
    this.numCorrect = 0;
  }

  /**
   * Launcher - launches app
   * 
   * @param args Command line arguments
   */
  public static void main(String[] args) {
    launch(args);
  }

}
