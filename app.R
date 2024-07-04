
# Load necessary libraries
library(shiny)
library(tm)
library(e1071)

# Load the pre-trained model
load("spam_model.RData")

# Define UI
ui <- fluidPage(
  tags$head(
    tags$style(
      HTML(
        "
        body {
          background-image: url('new1.jpg'); /* Change path to your image */
          background-size: cover;
          background-position: center;
          background-repeat: no-repeat;
          font-family: Arial, sans-serif;
          display: flex; /* Use flexbox for centering */
          justify-content: center; /* Center horizontally */
          align-items: center; /* Center vertically */
          height: 100vh; /* Set height to full viewport height */
        }
        .container {
          max-width: 600px;
          margin: 50px auto;
          padding: 40px;
          background-color: rgba(255, 255, 255, 0.8); /* Add opacity to make text readable */
          border-radius: 10px;
          box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
          backdrop-filter: blur(1px);
          
        }
        .title {
          text-align: center;
          color: black;
          font-size: 45px;
          margin-bottom: 10px;
          font-weight: bold;
          
        }
        .textInputWrapper {
          width: 100%;
          padding: 10px;
          font-size: 25px;
        }
        .actionBtn {
          width: 100%;
          padding: 10px;
          font-size: 25px;
          background-color:#5abaf2;
          color: white;
          border: 2px solid black;
          border-radius: 5px;
          cursor: pointer;
          margin-bottom:20px;
          transition: transform 0.2s ease;
        }
         .actionBtn:hover {
          background-color:#1890d6;/* Change to red on hover */
          transform: scale(1.1); 
        }
        .outputText {
          margin-top: 20px;
          padding: 10px;
          background-color: #f9f9f9;
          border: 1px solid #ccc;
          border-radius: 5px;
          color:black;
          transition: transform 0.2s ease;
        }
        .additionalText {
          text-align: center;
          color: white;
          padding:30px;
          font-size: 25px;
          margin-top: 20px;
          font-family: Arial, sans-serif;
          font-weight: bold;
        }
        "
      )
    )
  ),
  
  div(class = "container",
      div(class = "title", "Spam Detection App"),
      div(class = "textInputWrapper",
          textInput("text", "Enter text to classify:", placeholder = "Type your message here..." )),
      actionButton("classifyBtn", "Classify", class = "actionBtn"),
      verbatimTextOutput("prediction")
  ),
  div(class = "additionalText",
      "This app uses a machine learning model to detect spam messages. Enter text in the box above and click 'Classify' to see the prediction."
  )
)

# Define server logic
server <- function(input, output) {
  
  # Function to classify text
  classifyText <- function(text) {
    # Preprocess text
    text <- tolower(text)
    text <- removePunctuation(text)
    text <- removeNumbers(text)
    text <- removeWords(text, stopwords("en"))
    
    # Create document matrix
    text <- VectorSource(text)
    corpus <- Corpus(text)
    dtm <- DocumentTermMatrix(corpus)
    sparse_dtm <- removeSparseTerms(dtm, sparse = 0.95)
    
    # Convert sparse document-term matrix to a regular matrix
    dtm_matrix <- as.matrix(sparse_dtm)
    
    # Predict using the model
    prediction <- predict(spam_model, newdata = dtm_matrix)
    
    return(prediction)
  }
  
  # Event handler for classify button
  observeEvent(input$classifyBtn, {
    text <- input$text
    if (nchar(text) > 0) {
      prediction <- classifyText(text)
      output$prediction <- renderText({
        if (prediction == "spam") {
          return("This is a spam message.")
        } else {
          return("This is not a spam message.")
        }
      })
    } else {
      output$prediction <- renderText("Please enter some text.")
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)