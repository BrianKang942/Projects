package application;

import java.text.DecimalFormat;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

/**
 * 
 * @author aTeam87
 *
 */
public class ResultsDisplay {
	private Scene quizResults;

	/**
	 * 
	 * @param main
	 * @param primaryStage
	 */
	public ResultsDisplay(Main main, Stage primaryStage) {
		HBox root = new HBox();

		// labels to add to a VBox and display in HBox
		Label numQuestions = new Label("Number of questions:");
		Label ans1 = new Label("" + main.getSizeOfQuiz());
		Label correctQuestion = new Label("Number of correctly answered questions:");
		Label ans2 = new Label("" + main.getNumberCorrect());
		Label percentage = new Label("Percentage:");

		DecimalFormat df = new DecimalFormat("###.##");

		double percent = (double) ((double) (main.getNumberCorrect()) / (main.getSizeOfQuiz()) * 100);
		String formatedPercent = df.format(percent);
		Label ans3 = new Label("" + formatedPercent + "%");

		// Creates VBox for result labels
		VBox results = new VBox();
		results.getChildren().addAll(numQuestions, ans1, correctQuestion, ans2, percentage, ans3);
		root.getChildren().add(results); // adds VBox to HBox

		Button exit = new Button("Exit to Main Menu");
		exit.setOnAction(e -> {
			main.resetNumberCorrect();
			primaryStage.setScene(main.getMainMenu());
		});
		root.getChildren().add(exit);

		this.quizResults = new Scene(root, 800, 600);
	}

	public Scene getResultsScene() {
		return this.quizResults;
	}

}
