import spacy
from file_parser import FileParser
from query_executor import QueryExecutor
from evaluator import Evaluator

class MainController:

    def __init__(self, filename = 'extractions-all-labeled_nyt.txt') -> None:
        self.nlp = spacy.load('en_core_web_lg')
        self.fp = FileParser()
        self.fp.loadFile(filename)
        
    def main(self):
        fw = open("output_test.txt", "w")
        queryEx = QueryExecutor()

        for i in range(len(self.fp.sentences)): 
            sen = self.fp.sentences[i]
            doc = self.nlp(sen)
            tokens = []
            brackets = False
            for token in doc:
                if token.text == '(' and brackets == False:
                    brackets = True
                if token.text == ')' and brackets == True:
                    brackets = False
                if brackets == False and token.text!='(' and token.text!=')':
                    tokens.append([token.text, token.pos_])

            fw.write(str(i) + " " + sen + '\n' + str(tokens) + '\n')
            outputs = queryEx.query(tokens)
            self.fp.outputs[i] = outputs

            for triple in outputs:
                line = str(triple)
                line+='\n'
                fw.write(line)

        eval = Evaluator()
        eval.evaluate(self.fp)

        

if __name__ == '__main__':
    controller = MainController()
    controller.main()