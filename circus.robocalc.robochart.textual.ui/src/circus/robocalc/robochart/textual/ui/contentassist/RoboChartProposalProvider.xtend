/********************************************************************************
 * Copyright (c) 2019 University of York and others
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *   Alvaro Miyazawa - initial definition
 ********************************************************************************/

/*
 * generated by Xtext 2.17.1
 */
package circus.robocalc.robochart.textual.ui.contentassist

import circus.robocalc.robochart.Literal
import circus.robocalc.robochart.Variable
import circus.robocalc.robochart.textual.RoboChartQualifiedNameConverter
import circus.robocalc.robochart.textual.scoping.RoboChartScopeProvider
import com.google.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.Assignment
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.ui.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ui.editor.contentassist.ICompletionProposalAcceptor

import static circus.robocalc.robochart.RoboChartPackage.Literals.*

/**
 * See https://www.eclipse.org/Xtext/documentation/304_ide_concepts.html#content-assist
 * on how to customize the content assistant.
 */
class RoboChartProposalProvider extends AbstractRoboChartProposalProvider {
	@Inject
	RoboChartScopeProvider scope;

	@Inject
	RoboChartQualifiedNameConverter converter;

	override void completeRefExp_Ref(EObject model, Assignment assignment, ContentAssistContext context,
		ICompletionProposalAcceptor acceptor) {
		val variables = scope.variablesDeclared(model, IScope::NULLSCOPE).allElements
		for (v : variables) {
			val x = v.EObjectOrProxy as Variable
			acceptor.accept(createCompletionProposal(x.name, context))
		}
		val constants = scope.getScope(model, REF_EXP__REF)
		for (i : constants.allElements) {
			val o = i.EObjectOrProxy
			if (o instanceof Literal)
				acceptor.accept(createCompletionProposal(converter.toString(i.name), context))
		}
	}
}
