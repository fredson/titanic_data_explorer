library(shiny)
library(ggplot2)
library(dplyr)

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
  sidebarLayout(
    sidebarPanel(
      selectInput("pclass", "Passenger Class", choices = levels(train$Pclass)),
      selectInput("sex", "Sex", choices = levels(train$Sex)),
      numericInput("age", "Age", value = 30, min = 0, max = 100),
      numericInput("sibsp", "Siblings/Spouses", value = 0, min = 0, max = 8),
      numericInput("parch", "Parents/Children", value = 0, min = 0, max = 6),
      numericInput("fare", "Fare", value = mean(train$Fare)),
      selectInput("embarked", "Embarked", choices = levels(train$Embarked))
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
}

shinyApp(ui, server)