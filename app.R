library(shiny)
library(ggplot2)
library(dplyr)

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
    )
  )
)

server <- function(input, output, session) {
  passenger <- reactive({
    data.frame(
      Pclass = factor(input$Pclass, levels = levels(train_data$Pclass)),
      Sex = factor(input$Sex, levels = levels(train_data$Sex)),
      Age = input$Age,
      SibSp = input$SibSp,
      Parch = input$Parch,
      Fare = input$Fare,
      Embarked = factor(input$Embarked, levels = levels(train_data$Embarked))
    )
  })

  pred_prob <- reactive({
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
  })
}

shinyApp(ui, server)
