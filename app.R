library(shiny)
library(ggplot2)
library(dplyr)
<<<<<<< HEAD

# Load Titanic dataset from CSV (downloaded from Kaggle repo)
titanic_train <- read.csv('titanic_train.csv', stringsAsFactors = FALSE)

# Preprocess dataset: handle missing Age and Embarked
# We'll drop rows with missing values for simplicity
train_data <- titanic_train %>% 
  dplyr::select(Survived, Pclass, Sex, Age, SibSp, Parch, Fare, Embarked) %>%
  dplyr::filter(!is.na(Age), Embarked != '')

# Convert character variables to factors
train_data$Sex <- factor(train_data$Sex)
train_data$Embarked <- factor(train_data$Embarked)
train_data$Pclass <- factor(train_data$Pclass)

# Fit logistic regression model
survival_model <- glm(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare + Embarked,
                      data = train_data, family = binomial)

ui <- fluidPage(
  titlePanel('Titanic Survival Predictor'),
  sidebarLayout(
    sidebarPanel(
      selectInput('Pclass', 'Passenger Class', choices = sort(unique(train_data$Pclass))),
      selectInput('Sex', 'Sex', choices = levels(train_data$Sex)),
      numericInput('Age', 'Age', value = median(train_data$Age, na.rm = TRUE), min = 0, max = 80),
      numericInput('SibSp', 'Siblings/Spouses Aboard', value = 0, min = 0, max = 8),
      numericInput('Parch', 'Parents/Children Aboard', value = 0, min = 0, max = 6),
      numericInput('Fare', 'Fare', value = median(train_data$Fare, na.rm = TRUE), min = 0, step = 0.1),
      selectInput('Embarked', 'Port of Embarkation', choices = levels(train_data$Embarked))
    ),
    mainPanel(
      h3('Estimated Survival Probability'),
      textOutput('prediction'),
      plotOutput('plot')
=======
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
>>>>>>> zgra0g-codex/entwickle-web-app-zur-titanic-überlebenswahrscheinlichkeit
    )
  )
)

server <- function(input, output, session) {
<<<<<<< HEAD
  passenger <- reactive({
    data.frame(
      Pclass = factor(input$Pclass, levels = levels(train_data$Pclass)),
      Sex = factor(input$Sex, levels = levels(train_data$Sex)),
      Age = input$Age,
      SibSp = input$SibSp,
      Parch = input$Parch,
      Fare = input$Fare,
      Embarked = factor(input$Embarked, levels = levels(train_data$Embarked))
=======
  user_data <- reactive({
    data.frame(
      Pclass = factor(input$pclass, levels = levels(train$Pclass)),
      Sex = factor(input$sex, levels = levels(train$Sex)),
      Age = input$age,
      SibSp = input$sibsp,
      Parch = input$parch,
      Fare = input$fare,
      Embarked = factor(input$embarked, levels = levels(train$Embarked))
>>>>>>> zgra0g-codex/entwickle-web-app-zur-titanic-überlebenswahrscheinlichkeit
    )
  })

  pred_prob <- reactive({
<<<<<<< HEAD
    predict(survival_model, newdata = passenger(), type = 'response')
  })

  output$prediction <- renderText({
    prob <- pred_prob()
    paste0(round(prob * 100, 1), '% chance of survival')
  })

  output$plot <- renderPlot({
    prob <- pred_prob()
    ggplot(data.frame(prob = prob), aes(x = 1, y = prob)) +
      geom_col(fill = 'steelblue') +
      coord_cartesian(ylim = c(0, 1)) +
      geom_text(aes(label = paste0(round(prob * 100,1), '%')), vjust = -0.5) +
      labs(x = '', y = 'Survival Probability') +
      theme_minimal() +
      theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
=======
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
>>>>>>> zgra0g-codex/entwickle-web-app-zur-titanic-überlebenswahrscheinlichkeit
  })
}

shinyApp(ui, server)
