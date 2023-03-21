package application;

import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Alert;
import javafx.scene.control.Alert.AlertType;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.RadioButton;
import javafx.scene.control.ToggleGroup;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

/**
 * 
 * @author aTeam87
 *
 */
public class QuestionNode {
	private Question metadata; // topic, question, answer, etc.
	private QuestionNode next = null; // next question in quiz
	private Scene quizDisplay; // scene to display quiz

	/**
	 * 
	 * @param metaData
	 *            - data related to quiz question (topic, question, answer, etc.)
	 * @param main
	 *            - reference to main (gives access to needed functions)
	 * @param primaryStage
	 *            - primary stage
	 */
	public QuestionNode(Question metadata, Main main, Stage primaryStage) {
		this.metadata = metadata;

		// PrimaryStage.setTitle("QuizDisplay");
		BorderPane root = new BorderPane();

		// adds the image to the center left and resizes it
		Image image;
		ImageView imageview = new ImageView();
		try {
			// If the question has an accompanying image
			image = new Image(metadata.getImage());
			imageview = new ImageView(image);
		} catch (NullPointerException e) {
			// If the question does not have its own image
			image = new Image("application/questionMark.jpg");
			imageview = new ImageView(image);
		} catch (IllegalArgumentException e) {
			// If the question image filepath and/or spelling is wrong
			image = new Image("application/missingImage.png");
			imageview = new ImageView(image);
		}

		HBox hboxTwo = new HBox();
		imageview.setFitHeight(250);
		imageview.setFitWidth(350);
		hboxTwo.getChildren().add(imageview);
		hboxTwo.setAlignment(Pos.CENTER_LEFT);

		Label Question = new Label(metadata.getQuestion());

		// creates the radio buttons and adds them to a VBox thats within a HBox
		HBox hboxThree = new HBox();
		VBox vbox = new VBox();
		final ToggleGroup group = new ToggleGroup();

		vbox.getChildren().add(Question);
		Button button = new Button("Submit");
		button.setDisable(true);
		hboxThree.getChildren().add(vbox);
		hboxThree.setAlignment(Pos.TOP_LEFT);

		// Creates the submit button and aligns it

		HBox hbox = new HBox();
		hbox.getChildren().add(button);
		hbox.setAlignment(Pos.CENTER_RIGHT);

		button.setOnAction(e -> {
			if (group.getSelectedToggle().getUserData().equals(metadata.getAnswer().toString())) {
				main.incrementNumCorrect();
				Alert alert = new Alert(AlertType.INFORMATION);
				alert.setTitle("Question result");
				alert.setHeaderText(null);
				alert.setContentText("You got this question right");

				alert.showAndWait();
			} else {
				Alert alert = new Alert(AlertType.INFORMATION);
				alert.setTitle("Question result");
				alert.setHeaderText(null);
				alert.setContentText("You got this question wrong");
				alert.showAndWait();
			}
			if (this.getNext() == null) {
				primaryStage.setScene(new ResultsDisplay(main, primaryStage).getResultsScene());
			} else {
				primaryStage.setScene(this.getNext().getQuizDisplayScene());
			}

		});

		for (int i = 0; i < metadata.getChoices().size(); i++) {
			RadioButton answerOne = new RadioButton(metadata.getChoices().get(i));
			answerOne.setUserData(metadata.getChoices().get(i));
			answerOne.setToggleGroup(group);
			vbox.getChildren().add(answerOne);
			answerOne.setOnAction(e -> {
				button.setDisable(false);

			});

		}

		Button exitButton = new Button("Exit to Main Menu");
		exitButton.setOnAction(e -> {
			main.resetNumberCorrect();
			primaryStage.setScene(main.getMainMenu());
		});

		// adds the boxes to the Root
		root.setTop(hboxTwo);
		root.setBottom(hbox);
		root.setLeft(hboxThree);
		root.setRight(exitButton);

		this.quizDisplay = new Scene(root, 800, 600);
	}

	/**
	 * Sets the next question
	 * 
	 * @param next
	 *            node you wanna set
	 */
	public void setNext(QuestionNode next) {
		this.next = next;
	}

	/**
	 * Grabs the next question from the node
	 * 
	 * @return reference to the next question
	 */
	public QuestionNode getNext() {
		return this.next;
	}

	/**
	 * Displays the question to the GUI
	 * 
	 * @return the displayScene
	 */
	public Scene getQuizDisplayScene() {
		return this.quizDisplay;
	}

}
