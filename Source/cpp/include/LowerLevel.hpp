#include <Configuration.hpp>
#include <ProblemBounds.hpp>
#include <vector>
#include <OpenSim/Moco/osimMoco.h>

class LowerLevel 
{
    Configuration config;
    ProblemBounds bounds;
    std::vector<double> weights;
    OpenSim::MocoStudy study;
    public:
        LowerLevel(std::string, std::vector<double>);
        LowerLevel(Configuration, ProblemBounds, std::vector<double>);
        void configure();
        OpenSim::MocoProblem& updProblem();
        OpenSim::MocoCasADiSolver& updSolver();
        OpenSim::MocoSolution run();
    private:
        void initialise();
        void configureBounds();
        void configureSolver();
        void configureGuess();
};