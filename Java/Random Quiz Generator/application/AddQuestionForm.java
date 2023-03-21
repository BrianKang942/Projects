package application;

import java.util.ArrayList;

import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.RadioButton;
import javafx.scene.control.TextField;
import javafx.scene.control.ToggleGroup;
import javafx.scene.layout.GridPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

/**
 * 
 * @author aTeam87
 *
 */
public class AddQuestionForm {
	// Initialize fields
	private Scene questionFormScene;
	private GridPane grid = new GridPane();
	private ToggleGroup group = new ToggleGroup();

	/**
	 * 
	 * @param main
	 * @param primaryStage
	 */
	public AddQuestionForm(Main main, Stage primaryStage) {

		// Creating a GridPane container which will hold all textfields

		grid.setPadding(new Insets(10, 10, 10, 10));
		grid.setVgap(5);
		grid.setHgap(5);

		// Question textfield (user input)
		TextField newQuestion = new TextField();
		newQuestion.setPromptText("Question?");
		GridPane.setConstraints(newQuestion, 0, 0);
		grid.getChildren().add(newQuestion);

		// Topic textfield (user input)
		TextField newTopic = new TextField();
		newTopic.setPrefColumnCount(60);
		newTopic.setPromptText("Topic?");
		GridPane.setConstraints(newTopic, 0, 1);
		grid.getChildren().add(newTopic);

		// Image name textfield (user input)
		TextField ImageName = new TextField();
		ImageName.setPrefColumnCount(15);
		ImageName.setPromptText("Image Name?");
		GridPane.setConstraints(ImageName, 0, 2);
		grid.getChildren().add(ImageName);

		// label for user inputed answers
		Label label = new Label("Answers:");

		// RadioButton to allow users to check which answer is correct
		// TextField input next to each RadioButton to allow user inputed answers

		RadioButton button1 = new RadioButton();
		button1.setToggleGroup(group);

		TextField input1 = new TextField();
		input1.setPrefWidth(750);

		RadioButton button2 = new RadioButton();
		button2.setToggleGroup(group);
		TextField input2 = new TextField();
		input2.setPrefWidth(750);

		RadioButton button3 = new RadioButton("");
		button3.setToggleGroup(group);
		TextField input3 = new TextField();
		input3.setPrefWidth(750);

		RadioButton button4 = new RadioButton("");
		button4.setToggleGroup(group);
		TextField input4 = new TextField();
		input4.setPrefWidth(750);

		RadioButton button5 = new RadioButton("");
		button5.setToggleGroup(group);
		TextField input5 = new TextField();
		input5.setPrefWidth(750);

		group.getSelectedToggle();

		// After submitting the question form, should redirect back to Main Menu
		Button submit = new Button("Submit");
		submit.setOnAction(e -> {
			// Grabs user input of TextField
			String question = newQuestion.getText();
			String topic = newTopic.getText();
			String image = ImageName.getText();

			// if image file name not provided, put image as null
			if (image.trim().isEmpty()) {
				image = null;
			}

			// array for all answer choices
			ArrayList<String> choices = new ArrayList<String>();
			String answer1 = input1.getText();
			if (!(answer1.trim().isEmpty())) { // if answer choice left empty, do not add into array
				choices.add(answer1);
			}
			String answer2 = input2.getText();
			if (!(answer2.trim().isEmpty())) {
				choices.add(answer2);
			}

			String answer3 = input3.getText();
			if (!(answer3.trim().isEmpty())) {
				choices.add(answer3);
			}

			String answer4 = input4.getText();
			if (!(answer4.trim().isEmpty())) {
				choices.add(answer4);
			}

			String answer5 = input5.getText();
			if (!(answer5.trim().isEmpty())) {
				choices.add(answer5);
			}

			// Sets userData of buttons to user inputed answers
			button1.setUserData(answer1);
			button2.setUserData(answer2);
			button3.setUserData(answer3);
			button4.setUserData(answer4);
			button5.setUserData(answer5);

			// Grabs userData (answer) of the selected Toggle
			String correctAnswer = (String) group.getSelectedToggle().getUserData();

			Question Question = new Question(question, topic, correctAnswer, choices, image);

			// Returns question wrapper back to Main
			main.addQuestion(Question);

			primaryStage.setScene(main.getMainMenu());
		});

		// If user mistakenly opened question form, user can cancel form and is
		// redirected back to Main Menu
		Button cancel = new Button("Cancel");
		cancel.setOnAction(e -> primaryStage.setScene(main.getMainMenu()));
		HBox exitButtons = new HBox(submit, cancel);

		// VBox to organize every variable into vertical structure
		VBox root = new VBox();
		root.setPadding(new Insets(10));
		root.setSpacing(5);
		root.getChildren().addAll(grid, label, new HBox(button1, input1), new HBox(button2, input2),
				new HBox(button3, input3), new HBox(button4, input4), new HBox(button5, input5), exitButtons);

		this.questionFormScene = new Scene(root, 800, 600);
	}

	// Returns the Scene of the question Form - called when button "Add New
	// Question" is pressed
	public Scene getQuestionFormScene() {
		return this.questionFormScene;
	}
}
