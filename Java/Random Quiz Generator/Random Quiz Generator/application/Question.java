package application;

import java.util.ArrayList;

/**
 * Nodes containg metadata of questions
 * 
 * @author aTeam87
 *
 */
public class Question {
	// Private Fields:
	private String question;
	private String topic;
	private String answer;
	private ArrayList<String> choices;
	private String image;

	/**
	 * Sets private fields to corresponding parameters.
	 * 
	 * @param question
	 * @param topic
	 * @param answer
	 * @param choices
	 * @param image
	 */
	public Question(String question, String topic, String answer, ArrayList<String> choices, String image) {
		this.question = question;
		this.topic = topic;
		this.answer = answer;
		this.choices = choices;
		this.image = image;
	}

	// GETTERS

	// Getter for question
	public String getQuestion() {
		return this.question;
	}

	// Getter for topic
	public String getTopic() {
		return this.topic;
	}

	// Getter for answer
	public String getAnswer() {
		return this.answer;
	}

	// Getter for choices
	public ArrayList<String> getChoices() {
		return this.choices;
	}

	// Getter for image
	public String getImage() {
		return this.image;
	}

	// SETTERS (Unlikely to be needed, as no edit functionality is currently
	// planned)

	// Setter for question
	public void setQuestion(String answer) {
		this.question = question;
	}

	// Setter for topic
	public void setTopic(String answer) {
		this.topic = topic;
	}

	// Setter for anwer
	public void setAnswer(String answer) {
		this.answer = answer;
	}

	// Setter for choices
	public void setChoices(ArrayList<String> choices) {
		this.choices = choices;
	}

	// Setter for image
	public void setImage(String image) {
		this.image = image;
	}

}
