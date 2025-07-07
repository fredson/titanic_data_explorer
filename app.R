library(shiny)
library(ggplot2)
library(dplyr)
library(titanic)
library(tidyr)
# Daten laden
data(titanic_train, package = "titanic")

# Vorverarbeiten
train <- titanic_train %>%
  mutate(
    Survived = factor(Survived),
    Pclass = factor(Pclass),
    Sex = factor(Sex),
    Embarked = factor(Embarked)
  ) %>%
  drop_na()

# Modell trainieren
model <- glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
             data = train, family = binomial)

ui <- fluidPage(
  titlePanel("Titanic Survival Predictor"),
  p("Enter passenger details below to estimate survival odds using historical Titanic data."),
  sidebarLayout(
    sidebarPanel(
      selectInput("pclass", "Passenger Class", choices = levels(train$Pclass)),
      selectInput("sex", "Sex", choices = levels(train$Sex)),
      numericInput("age", "Age", value = 30, min = 0, max = 100),
      numericInput("sibsp", "Siblings/Spouses", value = 0, min = 0, max = 8),
      numericInput("parch", "Parents/Children", value = 0, min = 0, max = 6),
      numericInput("fare", "Fare", value = mean(train$Fare)),
      selectInput(
        "embarked",
        "Embarked Port",
        choices = c(
          "Cherbourg (C)" = "C",
          "Queenstown (Q)" = "Q",
          "Southampton (S)" = "S"
        ),
        selected = "S"
      ),
      br(),
      actionButton("reset_jack", "Jack Dawson"),
      actionButton("reset_rose", "Rose DeWitt Bukater")
    ),
    mainPanel(
      h3("Estimated Survival Probability:"),
      textOutput("probText"),
      plotOutput("probPlot")
    )
  )
)

server <- function(input, output, session) {
  user_data <- reactive({
    data.frame(
      Pclass = factor(input$pclass, levels = levels(train$Pclass)),
      Sex = factor(input$sex, levels = levels(train$Sex)),
      Age = input$age,
      SibSp = input$sibsp,
      Parch = input$parch,
      Fare = input$fare,
      Embarked = factor(input$embarked, levels = levels(train$Embarked))
    )
  })

  pred_prob <- reactive({
    predict(model, newdata = user_data(), type = "response")
  })

  output$probText <- renderText({
    sprintf("%.1f %%", pred_prob() * 100)
  })

  output$probPlot <- renderPlot({
    ggplot(train, aes(x = predict(model, type = "response"))) +
      geom_histogram(fill = "steelblue", bins = 30) +
      geom_vline(xintercept = pred_prob(), color = "red", linetype = "dashed", size = 1.2) +
      labs(x = "Predicted Survival Probability", y = "Count") +
      theme_minimal()
  })

  observeEvent(input$reset_jack, {
    updateSelectInput(session, "pclass", selected = "3")
    updateSelectInput(session, "sex", selected = "male")
    updateNumericInput(session, "age", value = 20)
    updateNumericInput(session, "sibsp", value = 0)
    updateNumericInput(session, "parch", value = 0)
    updateNumericInput(session, "fare", value = 5)
    updateSelectInput(session, "embarked", selected = "S")
  })

  observeEvent(input$reset_rose, {
    updateSelectInput(session, "pclass", selected = "1")
    updateSelectInput(session, "sex", selected = "female")
    updateNumericInput(session, "age", value = 17)
    updateNumericInput(session, "sibsp", value = 0)
    updateNumericInput(session, "parch", value = 1)
    updateNumericInput(session, "fare", value = 100)
    updateSelectInput(session, "embarked", selected = "S")
  })
}

shinyApp(ui, server)