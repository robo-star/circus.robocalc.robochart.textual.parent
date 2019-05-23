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
package circus.robocalc.robochart.textual.scoping

import circus.robocalc.robochart.Call
import circus.robocalc.robochart.CallExp
import circus.robocalc.robochart.ClockExp
import circus.robocalc.robochart.ClockReset
import circus.robocalc.robochart.Connection
import circus.robocalc.robochart.ConnectionNode
import circus.robocalc.robochart.Context
import circus.robocalc.robochart.ControllerDef
import circus.robocalc.robochart.ControllerRef
import circus.robocalc.robochart.DefiniteDescription
import circus.robocalc.robochart.Enumeration
import circus.robocalc.robochart.Exists
import circus.robocalc.robochart.Final
import circus.robocalc.robochart.Forall
import circus.robocalc.robochart.Function
import circus.robocalc.robochart.FunctionType
import circus.robocalc.robochart.Initial
import circus.robocalc.robochart.Interface
import circus.robocalc.robochart.LambdaExp
import circus.robocalc.robochart.LetExpression
import circus.robocalc.robochart.Literal
import circus.robocalc.robochart.NodeContainer
import circus.robocalc.robochart.OperationDef
import circus.robocalc.robochart.OperationRef
import circus.robocalc.robochart.OperationSig
import circus.robocalc.robochart.PrimitiveType
import circus.robocalc.robochart.RCModule
import circus.robocalc.robochart.RCPackage
import circus.robocalc.robochart.RecordType
import circus.robocalc.robochart.RefExp
import circus.robocalc.robochart.RoboticPlatformDef
import circus.robocalc.robochart.RoboticPlatformRef
import circus.robocalc.robochart.Selection
import circus.robocalc.robochart.SendEvent
import circus.robocalc.robochart.SetComp
import circus.robocalc.robochart.State
import circus.robocalc.robochart.StateClockExp
import circus.robocalc.robochart.StateMachineDef
import circus.robocalc.robochart.StateMachineRef
import circus.robocalc.robochart.Transition
import circus.robocalc.robochart.Trigger
import circus.robocalc.robochart.Type
import circus.robocalc.robochart.TypeDecl
import circus.robocalc.robochart.TypeRef
import circus.robocalc.robochart.VarRef
import circus.robocalc.robochart.VarSelection
import circus.robocalc.robochart.VariableModifier
import circus.robocalc.robochart.textual.RoboCalcTypeProvider
import com.google.inject.Inject
import java.util.ArrayList
import java.util.LinkedList
import java.util.List
import java.util.Queue
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.Scopes
import org.eclipse.xtext.scoping.impl.MultimapBasedScope

import static circus.robocalc.robochart.RoboChartPackage.Literals.*
import org.eclipse.xtext.EcoreUtil2

/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class RoboChartScopeProvider extends AbstractRoboChartScopeProvider {
	@Inject extension RoboCalcTypeProvider

	override getScope(EObject context, EReference reference) {
		if (context instanceof Connection) {
			return context.getScopeForConnection(reference)
		} else if (context instanceof Trigger) {
			return context.getTriggerScope(reference)
		} else if (context instanceof SendEvent) {
			return context.getSendEventScope(reference)
		} else if (context instanceof Selection) {
			if (reference === SELECTION__MEMBER) {
				val s = getSelectionScope(context.receiver.typeFor)
				return s
			}
		} else if (context instanceof VarSelection) {
			if (reference === VAR_SELECTION__MEMBER) {
				val s = getSelectionScope(context.receiver.typeFor)
				return s
			}
		}
		/* else if (context instanceof EnumExp) {
		 * 	if (reference === ENUM_EXP__CONSTANT) {
		 * 		var spec = context.eContainer
		 * 		while (!(spec instanceof RCPackage)) {
		 * 			spec = spec.eContainer
		 * 		}
		 * 		val constants = (spec as RCPackage).constants
		 * 		Scopes::scopeFor(constants)				
		 * 	}
		 }*/
		else if (context instanceof RefExp) {
			if (reference === REF_EXP__REF) {
				EcoreUtil2.resolveAll(context);
				/* this can be uncommented if we want constants to be in the global
				 * scope of the RCPackage the enumeration is declared. the autocomplete
				 * only offers the qualified name (don't know how to change that yet)
				 * 		var spec = context.eContainer
				 * 		while (!(spec instanceof RCPackage)) {
				 * 			spec = spec.eContainer
				 * 		}
				 * 		val constants = (spec as RCPackage).constants
				 */
				val result = IScope::NULLSCOPE // delegateGetScope(context, reference)
//				val predicate = new Predicate<IEObjectDescription>() {
//					override public boolean apply(IEObjectDescription input) {
//						val b1 = input.EObjectOrProxy instanceof Constant
//						val b2 = input.EObjectOrProxy instanceof Field
//						return b1 || b2
//					}
//				}
//				val objects = Iterables.filter(result.allElements, predicate)
//				val functions = context.functionsDeclared(result)
				val variables = context.variablesDeclared(result)//functions)
				val constants = context.variantsDeclared(variables)
				return constants
			// return new SimpleScope(variables, objects)
			}
			return super.getScope(context, reference)
		}
		/* else if (context instanceof VarExp) {
		 * 	if (reference === VAR_EXP__VALUE) {
		 * 		context.eContainer.variablesDeclared
		 * 	}
		 }*/
		else if (context instanceof VarRef) {
			if (reference === VAR_REF__NAME) {
				val result = delegateGetScope(context, reference)
				val r = context.variablesDeclared(result)
				r
			}
		} else if (context instanceof Call) {
			if (reference === CALL__OPERATION) {
				//changed the parent scope to avoid accepting OperationDefs being in the scope for Calls
				val s = IScope::NULLSCOPE//super.getScope(context, reference)
				return context.operationsDeclared(s)
			}
		} else if (context instanceof CallExp) {
			if (reference === CALL_EXP__FUNCTION) {
				var result = super.getScope(context, reference)
				return context.functionsDeclared(result)
			}
		} // Based on Pedro's code	
		else if (context instanceof ClockExp) {
			if (reference === CLOCK_EXP__CLOCK) {
				return context.eContainer.clocksDeclared
			}
		} else if (context instanceof ClockReset) {
			if (reference === CLOCK_RESET__CLOCK) {
				return context.eContainer.clocksDeclared
			}
		} else if (context instanceof StateClockExp) {
			if (reference === STATE_CLOCK_EXP__STATE) {
				val stm = contextOfSinceEntry(context)
				// val parentScope = delegateGetScope(context, reference)
				if (stm !== null)
					return stm.statesDeclared(IScope::NULLSCOPE)
				else
					return IScope::NULLSCOPE
			}
		}
		/*else if (context instanceof Label) {
		 * 	return context.labelScope
		 }*/
		else if (context instanceof TypeRef) {

			if (reference === TYPE_REF__REF) {
				var parentScope = delegateGetScope(context, reference);
				var scope = context.typesDeclared(parentScope)
				return scope
			}
		} else if (context instanceof Transition) {
			val r = delegateGetScope(context, reference)
			if (reference === TRANSITION__SOURCE) {
				if (context.eContainer instanceof NodeContainer) {
					return Scopes.scopeFor(
						(context.eContainer as NodeContainer).nodes.filter[n|!(n instanceof Final)],
						r
					)
				}
			} else if (reference === TRANSITION__TARGET) {
				if (context.eContainer instanceof NodeContainer) {
					return Scopes.scopeFor(
						(context.eContainer as NodeContainer).nodes.filter[n|!(n instanceof Initial)],
						r
					)
				}
			}
		}	
		else {
			val s = delegateGetScope(context, reference)
			return s
		}
	}

// calculates the types as those declared by the RCPackage, or by the RCPackage of the context
	def dispatch IScope typesDeclared(RCPackage o, IScope p) {
		if (o !== null && o.types !== null) {
			val othertypes = new ArrayList<TypeDecl>()

			val resources = o.eResource.resourceSet.resources
			for (r : resources) {
				if (!isAuxFile(r.URI.toString) && r.contents.size() > 0 && r.contents.get(0) instanceof RCPackage &&
					r.contents.get(0) !== o && (r.contents.get(0) as RCPackage).name === null) {
					othertypes.addAll((r.contents.get(0) as RCPackage).types)
				}
			}

			// the current types go last, otherwise there is a serialization error.
			// TODO: need to figure out a way of changing this
			othertypes.addAll(o.types)
			val scope = variantsDeclared(o,p);
			return (Scopes.scopeFor(othertypes, scope))
		}
		return p
	}

	def boolean isAuxFile(String s) {
		if (s.lastIndexOf(".rct") !== s.indexOf(".rct")) {
			return true;
		} else {
			return false
		}
	}

	def dispatch IScope typesDeclared(EObject o, IScope p) {
		if(o === null || o.eContainer === null) return p
		return o.eContainer.typesDeclared(p)
	}

	// calculates the robotic platforms as those declared by the RCPackage, or by the RCPackage of the context
	def dispatch IScope rpsDeclared(RCPackage o, IScope p) {
		if (o !== null && o.types !== null)
			return Scopes.scopeFor(o.robots, p)
		return p
	}

	def dispatch IScope rpsDeclared(RCModule o, IScope p) {
		if (o !== null && o.nodes !== null) {
			var pscope = p
			if (o.eContainer !== null) {
				pscope = rpsDeclared(o.eContainer, p)
			}
			var robots = o.nodes.filter(RoboticPlatformDef)
			return Scopes.scopeFor(robots, pscope)
		}
		return p
	}

	def dispatch IScope rpsDeclared(EObject o, IScope p) {
		if(o === null || o.eContainer === null) return p
		return o.eContainer.rpsDeclared(p)
	}

	// calculates the state machiens as those declared by the RCPackage, or by the RCPackage of the context
	def dispatch IScope stmsDeclared(RCPackage o, IScope p) {
		if (o !== null && o.types !== null)
			return Scopes.scopeFor(o.machines, p)
		return p
	}

	def dispatch IScope stmsDeclared(ControllerDef o, IScope p) {
		if (o !== null && o.machines !== null) {
			var pscope = p
			if (o.eContainer !== null) {
				pscope = stmsDeclared(o.eContainer, p)
			}
			return Scopes.scopeFor(o.machines, pscope)
		}
		return p
	}

	def dispatch IScope stmsDeclared(EObject o, IScope p) {
		if(o === null || o.eContainer === null) return p
		return o.eContainer.stmsDeclared(p)
	}

	// calculates the controllers as those declared by the RCPackage, or by the RCPackage of the context
	def dispatch IScope ctrlsDeclared(RCPackage o, IScope p) {
		if (o !== null && o.types !== null)
			return Scopes.scopeFor(o.controllers, p)
		return p
	}

	def dispatch IScope ctrlsDeclared(RCModule o, IScope p) {
		if (o !== null && o.nodes !== null) {
			var pscope = p
			if (o.eContainer !== null) {
				pscope = ctrlsDeclared(o.eContainer, p)
			}
			var ctrls = o.nodes.filter(ControllerDef)
			return Scopes.scopeFor(ctrls, pscope)
		}
		return p
	}

	def dispatch IScope ctrlsDeclared(EObject o, IScope p) {
		if(o === null || o.eContainer === null) return p
		return o.eContainer.ctrlsDeclared(p)
	}

	// calculates the interfaces as those declared by the RCPackage, or by the RCPackage of the context
	def dispatch IScope interfacesDeclared(RCPackage o, IScope p) {
		if (o !== null && o.types !== null)
			return Scopes.scopeFor(o.interfaces, p)
		return p
	}

	def dispatch IScope interfacesDeclared(EObject o, IScope p) {
		if(o === null || o.eContainer === null) return p
		return o.eContainer.interfacesDeclared(p)
	}

	def IScope getSelectionScope(Type t) {
		var parentScope = IScope::NULLSCOPE
		if (t instanceof TypeRef) {
			val type = t.ref
			if (type === null || type instanceof PrimitiveType || type instanceof Enumeration)
				return parentScope
			else if (type instanceof RecordType) {
				val datatype = type as RecordType
				return Scopes::scopeFor(datatype.fields, parentScope)
			}
		} else if (t instanceof FunctionType) {
			val functiontype = t as FunctionType
			return getSelectionScope(functiontype.range)
		} else
			return parentScope
	}

	def getTriggerScope(Trigger context, EReference reference) {
		if (reference === TRIGGER__EVENT) {
			var o = context.eContainer
			val result = delegateGetScope(context, reference)
			// while (!(o instanceof StateMachineDef || o === null)) {
			// o = o.eContainer
			// }
			// (o as StateMachineDef).eventsDeclared
			return o.eventsDeclared(result)
		} else if (reference === TRIGGER__TIME) {
			val result = delegateGetScope(context, reference)
			return context.eContainer.variablesDeclared(result)
		} else if (context instanceof Trigger && reference === TRIGGER__PARAMETER) {
			val result = delegateGetScope(context, reference)
			return context.variablesDeclared(result)
		} else if (context instanceof Trigger && reference === TRIGGER__FROM) {
			val result = delegateGetScope(context, reference)
			return context.variablesDeclared(result)
		} else {
			return delegateGetScope(context, reference)
		}
	}

	// don't think I need this
	def getSendEventScope(SendEvent context, EReference reference) {
		if (reference === SEND_EVENT__TRIGGER) {
			var o = context.eContainer
			val result = delegateGetScope(context, reference)
			/*while (!(o instanceof StateMachineDef || o === null)) {
			 * 	o = o.eContainer
			 }*/
			return o.eventsDeclared(result)
		} else {
			return delegateGetScope(context, reference)
		}
	}

	def getScopeForConnection(Connection context, EReference reference) {
		if (reference === CONNECTION__EFROM) {
			val result = delegateGetScope(context, reference)
			return context.from.eventsDeclared(result)
		} else if (reference === CONNECTION__ETO) {
			val result = delegateGetScope(context, reference)
			return context.to.eventsDeclared(result)
		} else if (reference === CONNECTION__FROM) {
			val result = delegateGetScope(context, reference)
			if (context === null) return result
			val parent = context.eContainer
			if (parent instanceof RCModule) {
				Scopes::scopeFor((parent as RCModule).nodes, result)
			} else if (parent instanceof ControllerDef) {
				Scopes::scopeFor((parent as ControllerDef).machines, result)
			} else
				result
		} else if (reference === CONNECTION__TO) {
			val result = delegateGetScope(context, reference)
			val parent = context.eContainer
			if (parent instanceof RCModule) {
				Scopes::scopeFor((parent as RCModule).nodes, result)
			} else if (parent instanceof ControllerDef) {
				Scopes::scopeFor((parent as ControllerDef).machines, result)
			} else
				result
		} else
			return delegateGetScope(context, reference)
	}

	// unlike types and operations, I don't need the parentScope because we cannot
	// declare events directly in a RCPackage, only on specific constructs
	// so the imported packages (by themselves) don't contribute to the scope
	def dispatch IScope eventsDeclared(RoboticPlatformDef n, IScope p) {
		var s = Scopes::scopeFor(n.events)
		for (Interface i : n.PInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.RInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.interfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		return s
	}

	def dispatch IScope eventsDeclared(RCModule n, IScope p) {
		val rp = n.roboticPlatform
		if(rp !== null) rp.eventsDeclared(p) else p
	}

	def dispatch IScope eventsDeclared(RoboticPlatformRef n, IScope p) {
		if (n.ref !== null) return n.ref.eventsDeclared(p)
		else return p
	}

	def dispatch IScope eventsDeclared(StateMachineDef n, IScope p) {
		var s = Scopes::scopeFor(n.events, p)
		for (Interface i : n.PInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.RInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.interfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		return s
	}

	def dispatch IScope eventsDeclared(OperationDef n, IScope p) {
		var s = Scopes::scopeFor(n.events, p)
		for (Interface i : n.PInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.RInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.interfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		return s

	// return n.eContainer.eventsDeclared
	}

	def dispatch IScope eventsDeclared(OperationRef n, IScope p) {
		if (n.ref !== null)
			n.ref.eventsDeclared(p)
		else p
	}

	def dispatch IScope eventsDeclared(StateMachineRef n, IScope p) {
		if (n.ref !== null) 
			n.ref.eventsDeclared(p)
		else p
	}

	def dispatch IScope eventsDeclared(ControllerDef n, IScope p) {
		var s = Scopes::scopeFor(n.events, p)
		for (Interface i : n.PInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.RInterfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		for (Interface i : n.interfaces) {
			s = Scopes::scopeFor(i.events, s)
		}
		return s
	}

	def dispatch IScope eventsDeclared(ControllerRef n, IScope p) {
		if (n.ref !== null) return n.ref.eventsDeclared(p)
		else return p
	}

	def dispatch IScope eventsDeclared(EObject cont, IScope p) {
		if (cont !== null && cont.eContainer !== null)
			cont.eContainer.eventsDeclared(p)
		else
			p
	}

	def dispatch IScope variablesDeclared(EObject cont, IScope p) {
		if (cont === null || cont.eContainer === null)
			return p
		else
			return cont.eContainer.variablesDeclared(p)
	}

	def dispatch IScope variablesDeclared(RCPackage cont, IScope p) {
		p
	}

	def dispatch IScope variablesDeclared(Context cont, IScope p) {
		var s = p
		for (l : cont.variableList) {
			s = Scopes::scopeFor(l.vars, s)
		}
		for (i : cont.RInterfaces) {
			for (l : i.variableList) {
				s = Scopes::scopeFor(l.vars, s)
			}
		}
		for (i : cont.interfaces) {
			for (l : i.variableList) {
				s = Scopes::scopeFor(l.vars, s)
			}
		}
		return s
	}

	def dispatch IScope variablesDeclared(OperationDef cont, IScope p) {
		var s = p
		s = Scopes::scopeFor(cont.parameters, s)
		for (l : cont.variableList) {
			s = Scopes::scopeFor(l.vars, s)
		}
		for (i : cont.RInterfaces) {
			for (l : i.variableList) {
				s = Scopes::scopeFor(l.vars, s)
			}
		}
		for (i : cont.interfaces) {
			for (l : i.variableList) {
				s = Scopes::scopeFor(l.vars, s)
			}
		}
		return s
	}

	def dispatch IScope variablesDeclared(Forall cont, IScope p) {
		var s = cont.eContainer.variablesDeclared(p)
		s = Scopes::scopeFor(cont.variables, s)
		return s
	}

	def dispatch IScope variablesDeclared(Exists cont, IScope p) {
		var s = cont.eContainer.variablesDeclared(p)
		s = Scopes::scopeFor(cont.variables, s)
		return s
	}

	def dispatch IScope variablesDeclared(LambdaExp cont, IScope p) {
		var s = cont.eContainer.variablesDeclared(p)
		s = Scopes::scopeFor(cont.variables, s)
		return s
	}

	def dispatch IScope variablesDeclared(LetExpression cont, IScope p) {
		var s = cont.eContainer.variablesDeclared(p)
		s = Scopes::scopeFor(cont.declarations, s)
		return s
	}

	def dispatch IScope variablesDeclared(DefiniteDescription cont, IScope p) {
		var s = cont.eContainer.variablesDeclared(p)
		s = Scopes::scopeFor(cont.variables, s)
		return s
	}

	def dispatch IScope variablesDeclared(SetComp cont, IScope p) {
		var s = cont.eContainer.variablesDeclared(p)
		s = Scopes::scopeFor(cont.variables, s)
		return s
	}

	def dispatch IScope variablesDeclared(Function cont, IScope p) {
		var s = p
		s = Scopes::scopeFor(cont.parameters, s)
		return s
	}

	def getRoboticPlatform(RCModule m) {
		for (ConnectionNode n : m.nodes) {
			if (n instanceof RoboticPlatformDef) {
				return n
			} else if (n instanceof RoboticPlatformRef) {
				return n.ref
			}
		}
		return null
	}

	def dispatch IScope operationsDeclared(EObject cont, IScope parent) {
		val container = cont.eContainer
		if (container !== null)
			container.operationsDeclared(parent)
		else
			parent
	}

	def dispatch IScope operationsDeclared(ControllerDef cont, IScope parent) {
		Scopes::scopeFor(
			cont.operations.filter[o|!(o instanceof OperationDef)],
			Scopes::scopeFor(
				cont.RInterfaces.operationsInInterfaces,
				Scopes::scopeFor(cont.PInterfaces.operationsInInterfaces, parent)
			)
		)
	}

	def dispatch IScope operationsDeclared(ControllerRef cont, IScope parent) {
		if (cont.ref !== null) cont.ref.operationsDeclared(parent)
		else parent
	}

	def dispatch IScope operationsDeclared(StateMachineDef cont, IScope parent) {
		Scopes::scopeFor(
			cont.operations.filter[o|!(o instanceof OperationDef)],
			Scopes::scopeFor(
				cont.RInterfaces.operationsInInterfaces,
				Scopes::scopeFor(
					cont.PInterfaces.operationsInInterfaces,
					parent//cont.eContainer.operationsDeclared(parent)
					// cannot use operationsDeclared of the controllers
				)
			)
		)
	}

	def dispatch IScope operationsDeclared(OperationDef cont, IScope parent) {
		Scopes::scopeFor(
			cont.operations.filter[o|!(o instanceof OperationDef)],
			Scopes::scopeFor(
				cont.RInterfaces.operationsInInterfaces,
				Scopes::scopeFor(
					cont.PInterfaces.operationsInInterfaces,
					parent//cont.eContainer.operationsDeclared(parent)
				)
			)
		)
	}

	def dispatch IScope operationsDeclared(RoboticPlatformDef cont, IScope parent) {
		Scopes::scopeFor(
			cont.operations.filter[o|!(o instanceof OperationDef)],
			Scopes::scopeFor(
				cont.RInterfaces.operationsInInterfaces,
				Scopes::scopeFor(cont.PInterfaces.operationsInInterfaces, parent)
			)
		)
	}

	def dispatch IScope operationsDeclared(RoboticPlatformRef cont, IScope parent) {
		if (cont.ref !== null) cont.ref.operationsDeclared(parent)
		else parent
	}

	def dispatch IScope operationsDeclared(RCPackage cont, IScope parent) {
		val s = Scopes::scopeFor(cont.operations.filter[o|!(o instanceof OperationDef)], parent)
		return s
	}

	def private operationsInInterfaces(List<Interface> list) {
		var operations = new ArrayList<OperationSig>();
		for (i : list) {
			operations.addAll(i.operations)
		}
		operations
	}

	def dispatch IScope operationsDeclared(Interface cont, IScope parent) {
		Scopes::scopeFor(
			cont.operations.filter[o|!(o instanceof OperationDef)],
			parent
		)
	}

// functions declared
	def dispatch IScope functionsDeclared(EObject cont, IScope parent) {
		val container = cont.eContainer
		if (container !== null)
			container.functionsDeclared(parent)
		else
			parent
	}

	def dispatch IScope functionsDeclared(RCPackage cont, IScope parent) {
		val s = Scopes::scopeFor(cont.functions, parent)
		return s
	}

	// Took these from Pedro's code in the previous scope provider
	/** @author: Pedro
	 *  Added to cope with timed variables.
	 *  At the moment these variables need to be declared as part
	 *  of the statemachine. Type information (discrete/continuous)
	 *  will be required somewhere.
	 */
	/*def IScope scope_Trigger_time(Trigger context, EReference r) {
	 * 	context.eContainer.variablesDeclared();
	 }*/
	/** @author: Pedro
	 * Added to properly find the time instants in state machines.
	 * At the moment the scope is the statemachine. 
	 * Type information (discrete/continuous) will be required somewhere.
	 */
	def dispatch IScope clocksDeclared(EObject cont) {
		if (cont !== null && cont.eContainer !== null)
			cont.eContainer.clocksDeclared();
	}

	def dispatch IScope clocksDeclared(StateMachineDef cont) {
		Scopes::scopeFor(cont.clocks)
	}

	def dispatch IScope clocksDeclared(OperationDef cont) {
		Scopes::scopeFor(cont.clocks)
	}

	def dispatch IScope clocksDeclared(Trigger cont) {
		cont.eContainer.clocksDeclared();
	}

	def dispatch IScope statesDeclared(EObject cont, IScope p) {
		if(cont.eContainer === null) return p else return cont.eContainer.statesDeclared(p);
	}

	def qualifiedName(State state) {
		var aux = state;
		var s = new LinkedList<String>()
		s.push(aux.getName())
		while (aux.eContainer() instanceof State) {
			aux = aux.eContainer() as State;
			s.push(aux.getName());
		}
		return QualifiedName.create(s);
	}

	def dispatch IScope statesDeclared(StateMachineDef cont, IScope p) {
		val l = order(cont).reverse
		var s = p
		for (x : l) {
			val ns = x.nodes.filter[n|n instanceof State && !(n instanceof Final)]
			if (ns.size > 0) {
				val list = new LinkedList<IEObjectDescription>()
				for (n : ns) {
					val qod = EObjectDescription.create((n as State).qualifiedName, n)
					val od = EObjectDescription.create((n as State).name, n)
					list.add(qod)
					list.add(od)
				}
				s = MultimapBasedScope.createScope(s, list, false)
			}
		}
		val ns = cont.nodes.filter[n|n instanceof State && !(n instanceof Final)]
		if (ns.size > 0) {
			val list = new LinkedList<IEObjectDescription>()
			for (n : ns) {
				val qod = EObjectDescription.create((n as State).qualifiedName, n)
				val od = EObjectDescription.create((n as State).name, n)
				list.add(qod)
				list.add(od)
			}
			s = MultimapBasedScope.createScope(s, list, false)
		}
		return s
	}

	// I have removed the cases for labelwithcontext, they will be treated in the labels plugins
	def StateMachineDef contextOfSinceEntry(StateClockExp e) {
		var EObject container = e
		while (container !== null && !(container instanceof StateMachineDef)) {
			container = container.eContainer
		}
		if (container instanceof StateMachineDef) {
			return container
		} else {
			return null
		}
	}

	def List<NodeContainer> order(NodeContainer nc) {
		val l = new LinkedList<NodeContainer>()

		val q = new LinkedList<NodeContainer>() as Queue<NodeContainer>
		q.offer(nc)
		while (!q.isEmpty) {
			val aux = q.poll
			for (x : aux.nodes) {
				if (x instanceof NodeContainer) {
					l.add(x)
					q.offer(x)
				}
			}
		}

//		for (x : nc.nodes) {
//			if (x instanceof NodeContainer) {
//				l.add(x)
//			}
//		}
//		for (x : nc.nodes) {
//			if (x instanceof NodeContainer) {
//				l.addAll(order(x))
//			}
//		}
		return l
	}

	// constant declaration
	def dispatch IScope variantsDeclared(EObject cont, IScope parent) {
		if (cont === null)
			return parent
		else if(cont.eContainer !== null) return cont.eContainer.variantsDeclared(parent) else return parent
	}

	def dispatch IScope variantsDeclared(RCPackage cont, IScope parent) {
		if(cont === null) return parent
		var constants = new LinkedList<Literal>();
		for (TypeDecl t : cont.types) {
			if (t instanceof Enumeration) {
				constants.addAll(t.literals);
			}
		}
//		var enums = new LinkedList<Enumeration>()
//		for (TypeDecl t: cont.types) {
//			if (t instanceof Enumeration) {
//				enums.add(t);
//			}
//		}
		Scopes::scopeFor(constants, parent)
	/*Scopes::scopeFor(constants, 
	 * 	new com.google.common.base.Function<Constant,QualifiedName>(){
	 * 		override apply(Constant input) {
	 * 			var parent = input.eContainer as Enumeration
	 * 			return QualifiedName.create(parent.name, input.name);
	 * 		}
	 * 	},
	 * 	parent
	 );*/
	}


	
	def dispatch IScope constantsDeclared(RoboticPlatformDef rp, IScope parent) {
				var s = parent
				for (l: rp.variableList) {
					if (l.modifier == VariableModifier.CONST) {
						s = Scopes.scopeFor(l.vars,s);
					}
				}
				for (i : rp.PInterfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				return s
	}
//	def dispatch Set<Variable> constantsDeclared(RoboticPlatformRef rp) {
//		return rp.ref.constantsDeclared
//	}
	def dispatch IScope constantsDeclared(RCModule m, IScope parent) {
		return m.roboticPlatform.constantsDeclared(parent)
	}
	def dispatch IScope constantsDeclared(StateMachineDef m, IScope parent) {
				var s = parent
				for (l: m.variableList) {
					if (l.modifier == VariableModifier.CONST) {
						s = Scopes.scopeFor(l.vars,s);
					}
				}
				for (i : m.RInterfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				for (i : m.interfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				return s	
	}
	
	def dispatch IScope constantsDeclared(OperationDef m, IScope parent) {
				var s = parent
				for (l: m.variableList) {
					if (l.modifier == VariableModifier.CONST) {
						s = Scopes.scopeFor(l.vars,s);
					}
				}
				for (i : m.RInterfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				for (i : m.interfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				if (m.parameters.length > 0) s = Scopes.scopeFor(m.parameters, s)
				return s	
	}
	
	def dispatch IScope constantsDeclared(ControllerDef m, IScope parent) {
				var s = parent
				for (l: m.variableList) {
					if (l.modifier == VariableModifier.CONST) {
						s = Scopes.scopeFor(l.vars,s);
					}
				}
				for (i : m.RInterfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				for (i : m.interfaces) {
					for (l: i.variableList) {
						if (l.modifier == VariableModifier.CONST) {
							s = Scopes.scopeFor(l.vars,s);
						}
					}
				}
				return s
	}
	
	def dispatch IScope constantsDeclared(EObject o, IScope parent) {
		parent
	}
}
